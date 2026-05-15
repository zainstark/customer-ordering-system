"""
API views for cart endpoints.

Mounted endpoints under `/api/cart/`:
 - GET /api/cart/ -> get_cart
 - POST /api/cart/items/ -> add_item_to_cart
 - PATCH /api/cart/items/{cart_item_id}/ -> update_cart_item
 - DELETE /api/cart/items/{cart_item_id}/delete/ -> remove_item_from_cart
 - POST /api/cart/validate/ -> validate_cart
 - DELETE /api/cart/clear/ -> clear_cart
"""

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Cart, CartItem
from .services import CartService
from .serializers import (
    CartSerializer,
    AddCartItemSerializer,
    UpdateCartItemSerializer,
)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_cart(request):
    """GET /api/cart/

    Retrieve the authenticated user's cart with nested items.
    """
    # Get or create cart for authenticated user
    # Note: In production, use request.user.account_id or similar
    # For now, we'll expect account_id in query params or headers
    account_id = request.GET.get('account_id') or getattr(
        request.user, 'account_id', None
    )
    
    if not account_id:
        return Response(
            {'error': 'account_id is required'},
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    cart = CartService.get_or_create_cart(account_id)
    serializer = CartSerializer(cart)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_item_to_cart(request):
    """POST /api/cart/items/

    Add item to cart.
    """
    # Validate request data
    serializer = AddCartItemSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    account_id = request.data.get('account_id') or getattr(
        request.user, 'account_id', None
    )
    
    if not account_id:
        return Response(
            {'error': 'account_id is required'},
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    # Get or create cart
    cart = CartService.get_or_create_cart(account_id)
    
    # Add item to cart
    menu_item_id = serializer.validated_data['menu_item_id']
    quantity = serializer.validated_data['quantity']
    
    cart_item, error = CartService.add_item_to_cart(
        cart.cart_id,
        menu_item_id,
        quantity,
    )
    
    if error:
        return Response(
            {'error': error},
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    # Return updated cart
    cart.refresh_from_db()
    cart_serializer = CartSerializer(cart)
    return Response(
        cart_serializer.data,
        status=status.HTTP_201_CREATED,
    )


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_cart_item(request, cart_item_id):
    """PATCH /api/cart/items/{cart_item_id}/

    Update quantity for an existing cart item.
    """
    # Validate request data
    serializer = UpdateCartItemSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    # Update item quantity
    new_quantity = serializer.validated_data['quantity']
    cart_item, error = CartService.update_item_quantity(
        cart_item_id,
        new_quantity,
    )
    
    if error:
        return Response(
            {'error': error},
            status=status.HTTP_404_NOT_FOUND,
        )
    
    # Return updated cart
    cart = cart_item.cart
    cart_serializer = CartSerializer(cart)
    return Response(
        cart_serializer.data,
        status=status.HTTP_200_OK,
    )


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_item_from_cart(request, cart_item_id):
    """DELETE /api/cart/items/{cart_item_id}/delete/

    Remove item from cart.
    """
    # Get cart_item to find parent cart
    try:
        cart_item = CartItem.objects.get(cart_item_id=cart_item_id)
        cart = cart_item.cart
    except CartItem.DoesNotExist:
        return Response(
            {'error': f'Cart item {cart_item_id} not found'},
            status=status.HTTP_404_NOT_FOUND,
        )
    
    # Remove item
    success, error = CartService.remove_item_from_cart(cart_item_id)
    
    if not success:
        return Response(
            {'error': error},
            status=status.HTTP_404_NOT_FOUND,
        )
    
    # Return updated cart
    cart.refresh_from_db()
    cart_serializer = CartSerializer(cart)
    return Response(
        cart_serializer.data,
        status=status.HTTP_200_OK,
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def validate_cart(request):
    """POST /api/cart/validate/

    Validate all cart items (availability and pricing consistency).
    """
    account_id = request.data.get('account_id') or getattr(
        request.user, 'account_id', None
    )
    
    if not account_id:
        return Response(
            {'error': 'account_id is required'},
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    # Get cart
    try:
        cart = Cart.objects.get(account_id=account_id)
    except Cart.DoesNotExist:
        return Response(
            {'error': f'Cart for account {account_id} not found'},
            status=status.HTTP_404_NOT_FOUND,
        )
    
    # Validate cart items
    is_valid, issues = CartService.validate_cart_items(cart.cart_id)
    
    response_data = {
        'is_valid': is_valid,
        'issues': issues,
        'cart_id': cart.cart_id,
    }
    
    return Response(response_data, status=status.HTTP_200_OK)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_cart(request):
    """DELETE /api/cart/clear/

    Clear all items from the account's cart.
    """
    account_id = request.data.get('account_id') or getattr(
        request.user, 'account_id', None
    )
    
    if not account_id:
        return Response(
            {'error': 'account_id is required'},
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    # Get cart
    try:
        cart = Cart.objects.get(account_id=account_id)
    except Cart.DoesNotExist:
        return Response(
            {'error': f'Cart for account {account_id} not found'},
            status=status.HTTP_404_NOT_FOUND,
        )
    
    # Clear cart
    success, error = CartService.clear_cart(cart.cart_id)
    
    if not success:
        return Response(
            {'error': error},
            status=status.HTTP_404_NOT_FOUND,
        )
    
    # Return empty cart
    cart.refresh_from_db()
    cart_serializer = CartSerializer(cart)
    return Response(
        cart_serializer.data,
        status=status.HTTP_200_OK,
    )


