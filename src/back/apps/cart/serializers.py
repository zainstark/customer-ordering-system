"""
DRF serializers for cart models.

Provides serialization/deserialization for Cart and CartItem models,
including menu item enrichment from dummy data.
"""

from rest_framework import serializers
from .models import Cart, CartItem
from .services import CartService


class CartItemSerializer(serializers.ModelSerializer):
    """Serializer for CartItem with menu item details."""

    menu_item_name = serializers.SerializerMethodField()
    menu_item_description = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = [
            'cart_item_id',
            'menu_item_id',
            'menu_item_name',
            'menu_item_description',
            'quantity',
            'unit_price_snapshot',
            'line_total',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'cart_item_id',
            'line_total',
            'created_at',
            'updated_at',
        ]

    def get_menu_item_name(self, obj):
        menu_item = CartService._get_menu_item(obj.menu_item_id)
        return menu_item['name'] if menu_item else 'Unknown Item'

    def get_menu_item_description(self, obj):
        menu_item = CartService._get_menu_item(obj.menu_item_id)
        return menu_item.get('description', '') if menu_item else ''


class CartSerializer(serializers.ModelSerializer):
    """Serializer for Cart with nested items and calculated total."""
    
    items = CartItemSerializer(
        many=True,
        source='cartitem_set',
        read_only=True,
    )
    cart_total = serializers.SerializerMethodField()
    item_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Cart
        fields = [
            'cart_id',
            'account_id',
            'status',
            'items',
            'item_count',
            'cart_total',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'cart_id',
            'account_id',
            'created_at',
            'updated_at',
        ]
    
    def get_cart_total(self, obj):
        """Calculate and return cart total."""
        return obj.get_cart_total()
    
    def get_item_count(self, obj):
        """Get total item count in cart."""
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
