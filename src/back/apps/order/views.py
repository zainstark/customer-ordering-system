"""
API views for the order app.

Mounted under /api/order/ in the root urls.py:

  GET  /api/order/        -> list_orders   (list all orders for the token account)
  POST /api/order/place/  -> place_order   (convert cart into a new order)

Both views are protected by IsAuthenticated.  The account_id is always
read from the JWT token via request.user.account_id — never from the
request body or query parameters.  This is identical to how cart/views.py
works and closes EC-UC7-01 (one account cannot see another's orders) and
EC-UC4-04 (client cannot inject a different account_id).
"""

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.order.serializers import OrderSerializer, PlaceOrderSerializer
from apps.order.services import OrderService


def _account_id(request) -> str:
    """
    Extract account_id from the authenticated request user.

    CustomJWTAuthentication (authentication/authentication.py) sets
    request.user to the Accounts model instance, which exposes
    account_id as its primary key field.
    """
    return getattr(request.user, "account_id", None)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def list_orders(request):
    """
    GET /api/order/

    Return all orders that belong to the authenticated account,
    newest first.  Returns an empty list when the account has no orders.

    Response 200:
        [ OrderSerializer, ... ]
    """
    orders = OrderService.get_orders_for_account(_account_id(request))
    serializer = OrderSerializer(orders, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def place_order(request):
    """
    POST /api/order/place/

    Convert the authenticated account's current cart into an order.

    Request body:
        { "address": "<delivery address>" }

    Response 201:
        OrderSerializer (the newly created order)

    Response 400:
        { "error": "<reason>" }   — empty cart, unavailable item,
                                    missing address, etc.
    """
    # Validate request body first. If address is missing this returns 400
    # before the service is ever called (covers test_place_order_missing_address).
    input_serializer = PlaceOrderSerializer(data=request.data)
    if not input_serializer.is_valid():
        return Response(input_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    order, error = OrderService.place_order(
        account_id=_account_id(request),
        address=input_serializer.validated_data["address"],
    )

    if error:
        return Response({"error": error}, status=status.HTTP_400_BAD_REQUEST)

    serializer = OrderSerializer(order)
    return Response(serializer.data, status=status.HTTP_201_CREATED)