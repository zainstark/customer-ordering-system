"""
DRF serializers for cart models.

Provides serialization/deserialization for Cart and CartItem models,
including menu item enrichment from dummy data.
"""

from rest_framework import serializers

from .models import Cart, CartItem
from .services import CartService


class CartItemSerializer(serializers.ModelSerializer):
    """Serializer for CartItem in Flutter-compatible shape."""

    id = serializers.CharField(source='cart_item_id', read_only=True)
    cartId = serializers.CharField(source='cart.cart_id', read_only=True)
    menuItemId = serializers.CharField(source='menu_item_id', read_only=True)
    title = serializers.SerializerMethodField()
    subtitle = serializers.SerializerMethodField()
    unitPrice = serializers.SerializerMethodField()
    imageUrl = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = [
            'id',
            'cartId',
            'menuItemId',
            'title',
            'subtitle',
            'unitPrice',
            'quantity',
            'imageUrl',
        ]
        read_only_fields = [
            'id',
            'cartId',
            'menuItemId',
            'title',
            'subtitle',
            'unitPrice',
            'imageUrl',
        ]

    def _get_menu_item(self, obj):
        menu_item = CartService._get_menu_item(obj.menu_item_id)
        return menu_item or {}

    def get_title(self, obj):
        return self._get_menu_item(obj).get('name', 'Unknown Item')

    def get_subtitle(self, obj):
        return self._get_menu_item(obj).get('description') or ''

    def get_unitPrice(self, obj):
        return float(obj.unit_price_snapshot) / 100.0

    def get_imageUrl(self, obj):
        menu_item = self._get_menu_item(obj)
        return menu_item.get('image_url') or menu_item.get('imageUrl') or ''


class CartSerializer(serializers.ModelSerializer):
    """Serializer for Cart response with nested Flutter-compatible items."""

    items = CartItemSerializer(
        many=True,
        read_only=True,
    )
    cartId = serializers.CharField(source='cart_id', read_only=True)
    accountId = serializers.CharField(source='account_id', read_only=True)
    cartTotal = serializers.SerializerMethodField()
    itemCount = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = [
            'cartId',
            'accountId',
            'items',
            'itemCount',
            'cartTotal',
        ]
        read_only_fields = [
            'cartId',
            'accountId',
            'items',
            'itemCount',
            'cartTotal',
        ]

    def get_cartTotal(self, obj):
        return float(obj.get_cart_total()) / 100.0

    def get_itemCount(self, obj):
        return obj.get_item_count()


class AddCartItemSerializer(serializers.Serializer):
    """Serializer for adding item to cart."""
    
    menu_item_id = serializers.CharField(max_length=36)
    quantity = serializers.IntegerField(min_value=1)
    
    def validate_quantity(self, value):
        """Validate quantity is positive."""
        if value < 1:
            raise serializers.ValidationError("Quantity must be at least 1")
        return value


class UpdateCartItemSerializer(serializers.Serializer):
    """Serializer for updating cart item quantity."""
    
    quantity = serializers.IntegerField(min_value=1)
    
    def validate_quantity(self, value):
        """Validate quantity is positive."""
        if value < 1:
            raise serializers.ValidationError("Quantity must be at least 1")
        return value


class CartValidationResponseSerializer(serializers.Serializer):
    """Serializer for cart validation response."""
    
    is_valid = serializers.BooleanField()
    issues = serializers.ListField(child=serializers.DictField())
