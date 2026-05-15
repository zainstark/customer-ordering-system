from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.throttling import UserRateThrottle
from rest_framework.exceptions import ValidationError, NotFound

from apps.order.services import OrderService
from apps.order.serializers import OrderSerializer
from apps.order.models import Order

# EC-UC7-05: Rate Limiting to prevent high-frequency polling
class OrderTrackingRateThrottle(UserRateThrottle):
    rate = '30/min' 

class PlaceOrderView(APIView):
    """
    POST /orders/place/
    Creates a new order from the user's active cart.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        idempotency_key = request.headers.get('Idempotency-Key')
        
        # API Constraint: Enforce idempotency key in headers
        if not idempotency_key:
            return Response(
                {"detail": "Idempotency-Key header is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Assuming the auth middleware attaches account_id to the user object
        account_id = getattr(request.user, 'account_id', str(request.user.id))

        try:
            # Delegate business logic to the service layer
            order, created = OrderService.create_order(
                account_id=account_id, 
                idempotency_key=idempotency_key
            )
            
            serializer = OrderSerializer(order)
            # 201 if new, 200 if duplicate request caught by idempotency cache
            status_code = status.HTTP_201_CREATED if created else status.HTTP_200_OK
            
            return Response(serializer.data, status=status_code)

        except ValidationError as e:
            # Catch known business logic violations (empty cart, price changes, etc.)
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            # EC-UC4-05: Database Write Failure generic handling
            # Note: In a production environment, log 'e' to a monitoring tool here.
            return Response(
                {"detail": "We were unable to create your order. Please try again."}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class TrackOrderView(APIView):
    """
    GET /order/<order_id>/track/
    Retrieves the real-time status of a specific order.
    """
    permission_classes = [IsAuthenticated]
    throttle_classes = [OrderTrackingRateThrottle] # Applies the 30/min limit

    def get(self, request, order_id, *args, **kwargs):
        account_id = getattr(request.user, 'account_id', str(request.user.id))

        try:
            # EC-UC7-01 & EC-UC7-02: Ensure order exists AND belongs to the authenticated user.
            # We prefetch related items to optimize the database query (N+1 prevention).
            order = Order.objects.prefetch_related('items', 'status_history').get(
                order_id=order_id,
                account_id=account_id
            )
        except Order.DoesNotExist:
            # We return a generic 404 for both non-existent IDs and IDs belonging 
            # to other users to prevent order enumeration attacks.
            raise NotFound(detail="Order not found. Please check your order ID and try again.")

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_200_OK)