from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from .serializers import CreateOrderRequestSerializer, OrderResponseSerializer
from .services import OrderService, PriceMismatchError, ItemUnavailableError

class PlaceOrderView(APIView):
    permission_classes = [IsAuthenticated] 

    def post(self, request):
        serializer = CreateOrderRequestSerializer(data=request.data)
        if not serializer.is_valid():
            # Extract first validation error as a simple message string for Flutter
            first_error = next(iter(serializer.errors.values()))[0]
            return Response({"message": str(first_error)}, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        account_id = str(request.user.id)
        service = OrderService()

        try:
            order = service.create_order(
                account_id=account_id,
                cart_items=data['items'],
                expected_total_cents=data['expected_total_cents']
            )
            response_data = OrderResponseSerializer(order).data
            return Response(response_data, status=status.HTTP_201_CREATED)

        # Catch exceptions and return {"message": ...} to satisfy DioException -> AppException
        except ValueError as e:
            return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except PriceMismatchError as e:
            return Response({"message": str(e)}, status=status.HTTP_409_CONFLICT)
        except ItemUnavailableError as e:
            return Response({"message": str(e)}, status=status.HTTP_409_CONFLICT)