from rest_framework import serializers
from .models import Order, OrderItem

class CartItemInputSerializer(serializers.Serializer):
    id = serializers.CharField()
    name = serializers.CharField()
    price_cents = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1)

class CreateOrderRequestSerializer(serializers.Serializer):
    expected_total_cents = serializers.IntegerField()
    payment_method = serializers.CharField()
    items = CartItemInputSerializer(many=True)

class OrderResponseSerializer(serializers.ModelSerializer):
    # Mapping to Flutter Contract: { id, accountId, orderId, status, placedAt, totalAmount, progress }
    id = serializers.UUIDField(source='order_id')
    accountId = serializers.CharField(source='account_id')
    orderId = serializers.UUIDField(source='order_id')
    status = serializers.CharField(source='order_status')
    placedAt = serializers.DateTimeField(source='placed_at')
    totalAmount = serializers.IntegerField(source='total_amount')
    progress = serializers.SerializerMethodField()
    
    class Meta:
        model = Order
        fields = ['id', 'accountId', 'orderId', 'status', 'placedAt', 'totalAmount', 'progress']

    def get_progress(self, obj):
        # Maps status to Flutter's expected progress indicator
        return {'PENDING': 0.1, 'CONFIRMED': 0.3, 'PREPARING': 0.5, 'READY': 0.7, 'OUT_FOR_DELIVERY': 0.9, 'DELIVERED': 1.0}.get(obj.order_status, 0.0)