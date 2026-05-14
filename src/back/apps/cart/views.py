"""
API views for cart endpoints.

Provides REST endpoints for managing shopping carts:
- GET /api/cart/ - Retrieve current user's cart
- POST /api/cart/items/ - Add item to cart
- PATCH /api/cart/items/{id}/ - Update item quantity
- DELETE /api/cart/items/{id}/ - Remove item from cart
- POST /api/cart/validate/ - Validate cart items
- DELETE /api/cart/ - Clear entire cart
"""

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Cart, CartItem
from .services import CartService
from .serializers import CartItemSerializer, UpdateCartItemSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_cart(request):
    """
    GET /api/cart/
    
    Retrieve the current authenticated user's cart with all items.
    
    Returns:
        - 200: Cart object with nested items and total
        - 404: Cart not found (shouldn't happen with get_or_create)
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
    """
    POST /api/cart/items/
    
    Add item to cart.
    
    Request body:
        {
            "account_id": "customer-123",  # Required
            "menu_item_id": "menu_001",
            "quantity": 2
        }
    
    Returns:
        - 201: CartItem created/updated
        - 400: Validation error (invalid quantity, item not found, etc)
        - 404: Cart not found
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
    """
    PATCH /api/cart/items/{cart_item_id}/
    
    Update quantity of item in cart.
    
    Request body:
        {
            "quantity": 3
        }
    
    Returns:
        - 200: CartItem updated, returns updated cart
        - 400: Validation error
        - 404: CartItem not found
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
    """
    DELETE /api/cart/items/{cart_item_id}/
    
    Remove item from cart.
    
    Returns:
        - 200: Item removed, returns updated cart
        - 404: CartItem not found
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
    """
    POST /api/cart/validate/
    
    Validate all items in cart (check availability and pricing).
    
    Request body:
        {
            "account_id": "customer-123"
        }
    
    Returns:
        - 200: Validation result
        {
            "is_valid": true/false,
            "issues": [
                {
                    "cart_item_id": "...",
                    "menu_item_id": "...",
                    "issue": "Item is out of stock",
                    ...
                }
            ]
        }
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
    """
    DELETE /api/cart/
    
    Clear all items from cart.
    
    Request body:
        {
            "account_id": "customer-123"
        }
    
    Returns:
        - 200: Cart cleared, returns empty cart
        - 404: Cart not found
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


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cart_detail(request, cart_id):
    """GET /carts/{cartId} -> returns the cart items list."""
    try:
        cart = Cart.objects.get(cart_id=cart_id)
    except Cart.DoesNotExist:
        return Response(
            {'error': f'Cart {cart_id} not found'},
            status=status.HTTP_404_NOT_FOUND,
        )

    items = CartItem.objects.filter(cart=cart).order_by('created_at')
    serializer = CartItemSerializer(items, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def cart_item_detail(request, cart_id, cart_item_id):
    """PUT or DELETE /carts/{cartId}/items/{cartItemId}."""
    try:
        cart = Cart.objects.get(cart_id=cart_id)
    except Cart.DoesNotExist:
        return Response(
            {'error': f'Cart {cart_id} not found'},
            status=status.HTTP_404_NOT_FOUND,
        )

    try:
        cart_item = CartItem.objects.get(cart=cart, cart_item_id=cart_item_id)
    except CartItem.DoesNotExist:
        return Response(
            {'error': f'Cart item {cart_item_id} not found'},
            status=status.HTTP_404_NOT_FOUND,
        )

    if request.method == 'DELETE':
        cart_item.delete()
        cart.refresh_from_db()
        items = CartItem.objects.filter(cart=cart).order_by('created_at')
        serializer = CartItemSerializer(items, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    serializer = UpdateCartItemSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    cart_item.quantity = serializer.validated_data['quantity']
    cart_item.save()
    cart.refresh_from_db()

    items = CartItem.objects.filter(cart=cart).order_by('created_at')
    serializer = CartItemSerializer(items, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)
