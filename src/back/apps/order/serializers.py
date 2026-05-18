"""
DRF serializers for the order app.

OrderItemLineSerializer   — nested line items inside an order response.
OrderSerializer           — full order response consumed by Flutter.
PlaceOrderSerializer      — validates the incoming place-order request body.

Field naming follows the Flutter models exactly:
  OrderItemModel.fromMap  reads: id, accountId, orderId, status,
                                 placedAt, totalAmount, progress
  Nested item shape       reads: id, title, unitPrice, quantity, lineTotal
"""

from rest_framework import serializers

from apps.order.models import Orders as Order, OrderItems


# ---------------------------------------------------------------------------
# Progress mapping
# ---------------------------------------------------------------------------

_PROGRESS_MAP = {
    "PENDING":          0.1,
    "CONFIRMED":        0.25,
    "PREPARING":        0.5,
    "READY":            0.75,
    "OUT_FOR_DELIVERY": 0.9,
    "DELIVERED":        1.0,
    "CANCELLED":        0.0,
    "REFUNDED":         0.0,
    "FAILED":           0.0,
}


# ---------------------------------------------------------------------------
# OrderItemLineSerializer
# ---------------------------------------------------------------------------

class OrderItemLineSerializer(serializers.ModelSerializer):
    """
    Serializes a single OrderItem line as the Flutter client expects it.

    DB field          -> JSON key    notes
    order_item_id     -> id
    item_name_snapshot-> title
    unit_price_snapshot-> unitPrice  pennies ÷ 100, float dollars
    quantity          -> quantity    integer, unchanged
    line_total        -> lineTotal   pennies ÷ 100, float dollars
    """

    id = serializers.CharField(source="order_item_id", read_only=True)
    title = serializers.CharField(source="item_name_snapshot", read_only=True)
    unitPrice = serializers.SerializerMethodField()
    lineTotal = serializers.SerializerMethodField()

    class Meta:
        model = OrderItems
        fields = [
            "id",
            "title",
            "unitPrice",
            "quantity",
            "lineTotal",
        ]

    def get_unitPrice(self, obj: OrderItems) -> float:
        return obj.unit_price_snapshot / 100.0

    def get_lineTotal(self, obj: OrderItems) -> float:
        return obj.line_total / 100.0


# ---------------------------------------------------------------------------
# OrderSerializer
# ---------------------------------------------------------------------------

class OrderSerializer(serializers.ModelSerializer):
    """
    Serializes a full Order with nested line items.

    DB field      -> JSON key      notes
    order_id      -> orderId
    account_id    -> accountId
    order_status  -> status        raw string e.g. "PENDING"
    placed_at     -> placedAt      ISO-8601 datetime string
    total_amount  -> totalAmount   pennies ÷ 100, float dollars
    (computed)    -> progress      float 0.0–1.0 derived from order_status
    items (FK)    -> items         nested OrderItemLineSerializer list
    """

    orderId = serializers.CharField(source="order_id", read_only=True)
    accountId = serializers.CharField(source="account_id", read_only=True)
    status = serializers.CharField(source="order_status", read_only=True)
    placedAt = serializers.DateTimeField(source="placed_at", read_only=True)
    totalAmount = serializers.SerializerMethodField()
    progress = serializers.SerializerMethodField()
    items = OrderItemLineSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            "orderId",
            "accountId",
            "status",
            "placedAt",
            "totalAmount",
            "progress",
            "items",
        ]

    def get_totalAmount(self, obj: Order) -> float:
        return obj.total_amount / 100.0

    def get_progress(self, obj: Order) -> float:
        # Unknown statuses default to 0.0 so the Flutter progress bar
        # never receives a value outside [0.0, 1.0].
        return _PROGRESS_MAP.get(obj.order_status, 0.0)


# ---------------------------------------------------------------------------
# Tracking Serializers
# ---------------------------------------------------------------------------

_TRACKING_PROGRESS_MAP = {
    "PENDING":          0,
    "CONFIRMED":        20,
    "PREPARING":        50,
    "READY":            70,
    "OUT_FOR_DELIVERY": 90,
    "DELIVERED":        100,
    "CANCELLED":        0,
    "REFUNDED":         0,
    "FAILED":           0,
}

_ETA_MAP = {
    "PENDING": 45,
    "CONFIRMED": 35,
    "PREPARING": 20,
    "READY": 15,
    "OUT_FOR_DELIVERY": 5,
    "DELIVERED": 0,
    "CANCELLED": 0,
    "REFUNDED": 0,
    "FAILED": 0,
}

class OrderTrackingHistorySerializer(serializers.ModelSerializer):
    status = serializers.SerializerMethodField()
    timestamp = serializers.DateTimeField(source="changed_at", read_only=True)

    class Meta:
        from apps.order.models import OrderStatusHistory
        model = OrderStatusHistory
        fields = ["status", "timestamp"]

    def get_status(self, obj) -> str:
        s = obj.order_status.lower()
        if s == "out_for_delivery":
            return "delivery"
        return s

class OrderTrackingSerializer(serializers.ModelSerializer):
    orderId = serializers.CharField(source="order_id", read_only=True)
    accountId = serializers.CharField(source="account_id", read_only=True)
    status = serializers.CharField(source="order_status", read_only=True)
    placedAt = serializers.DateTimeField(source="placed_at", read_only=True)
    totalAmount = serializers.SerializerMethodField()
    progress = serializers.SerializerMethodField()
    items = OrderItemLineSerializer(many=True, read_only=True)
    currentStatus = serializers.SerializerMethodField()
    estimatedTimeMinutes = serializers.SerializerMethodField()
    history = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            "orderId",
            "accountId",
            "status",
            "placedAt",
            "totalAmount",
            "progress",
            "items",
            "currentStatus",
            "estimatedTimeMinutes",
            "history",
        ]

    def get_totalAmount(self, obj: Order) -> float:
        return obj.total_amount / 100.0

    def get_progress(self, obj: Order) -> int:
        return _TRACKING_PROGRESS_MAP.get(obj.order_status, 0)

    def get_currentStatus(self, obj: Order) -> str:
        s = obj.order_status.lower()
        if s == "out_for_delivery":
            return "delivery"
        return s

    def get_estimatedTimeMinutes(self, obj: Order) -> int:
        return _ETA_MAP.get(obj.order_status, 0)

    def get_history(self, obj: Order):
        # The view should prefetch or pass history. If history is passed as a context variable:
        history = self.context.get("history")
        if history is not None:
            return OrderTrackingHistorySerializer(history, many=True).data
        return []


# ---------------------------------------------------------------------------
# PlaceOrderSerializer
# ---------------------------------------------------------------------------

class PlaceOrderSerializer(serializers.Serializer):
    """
    Validates the body of POST /api/order/place/.

    Only `address` is accepted.  Any other fields the client sends
    (e.g. a tampered account_id or price) are silently ignored because
    this serializer does not declare them — they never reach the service.
    """

    address = serializers.CharField(max_length=500)