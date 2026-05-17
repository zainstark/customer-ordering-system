from rest_framework import serializers


class CreatePaymentSessionSerializer(serializers.Serializer):
    order_id = serializers.CharField(max_length=64, required=False)
    payment_method = serializers.CharField(max_length=50, required=False)
    amount = serializers.FloatField(required=False)
    orderId = serializers.CharField(max_length=64, required=False)
    paymentMethod = serializers.CharField(max_length=50, required=False)

    def validate(self, attrs):
        order_id = attrs.get("order_id") or attrs.get("orderId")
        payment_method = attrs.get("payment_method") or attrs.get("paymentMethod")
        if not order_id:
            raise serializers.ValidationError({"order_id": "This field is required."})
        if not payment_method:
            raise serializers.ValidationError({"payment_method": "This field is required."})
        attrs["order_id"] = order_id
        attrs["payment_method"] = payment_method
        return attrs


class PaymentSessionSerializer(serializers.Serializer):
    payment_id = serializers.CharField(read_only=True)
    payment_intent_id = serializers.CharField(read_only=True)
    client_secret = serializers.CharField(read_only=True)
    checkout_url = serializers.CharField(read_only=True)
    status = serializers.CharField(read_only=True)


class PaymentStatusSerializer(serializers.Serializer):
    payment_id = serializers.CharField(read_only=True)
    order_id = serializers.CharField(read_only=True)
    status = serializers.CharField(read_only=True)
    amount = serializers.FloatField(read_only=True)
    payment_method = serializers.CharField(read_only=True)


class RetryPaymentSerializer(serializers.Serializer):
    retry_count = serializers.IntegerField(read_only=True)
    nextAttempt = serializers.DateTimeField(read_only=True, required=False)


class WebhookEventSerializer(serializers.Serializer):
    event_type = serializers.CharField(max_length=100)
    data = serializers.DictField()
