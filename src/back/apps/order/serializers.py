from rest_framework import serializers
from apps.order.models import Order, OrderItem, OrderStatusHistory

class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = [
            'order_item_id', 
            'menu_item_id', 
            'item_name_snapshot', 
            'unit_price_snapshot', 
            'quantity', 
            'line_total'
        ]

class OrderStatusHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderStatusHistory
        fields = ['order_status', 'note', 'changed_at']

class OrderSerializer(serializers.ModelSerializer):
    # Nested relationships based on the 'related_name' in models.py
    items = OrderItemSerializer(many=True, read_only=True)
    status_history = OrderStatusHistorySerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            'order_id', 
            'account_id', 
            'total_amount', 
            'placed_at', 
            'order_status', 
            'confirmed_at', 
            'updated_at', 
            'items', 
            'status_history'
        ]