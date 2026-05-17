from rest_framework import serializers


class CreatePaymentSessionSerializer(serializers.Serializer):
    orderId = serializers.CharField(max_length=36)
    paymentMethod = serializers.CharField(max_length=50)


class PaymentSessionSerializer(serializers.Serializer):
    paymentId = serializers.CharField(read_only=True)
    checkoutUrl = serializers.CharField(read_only=True)
    status = serializers.CharField(read_only=True)


class PaymentStatusSerializer(serializers.Serializer):
    paymentId = serializers.CharField(read_only=True)
    orderId = serializers.CharField(read_only=True)
    status = serializers.CharField(read_only=True)
    amount = serializers.FloatField(read_only=True)
    paymentMethod = serializers.CharField(read_only=True)


class RetryPaymentSerializer(serializers.Serializer):
    retryCount = serializers.IntegerField(read_only=True)
    nextAttempt = serializers.DateTimeField(read_only=True, required=False)


class WebhookEventSerializer(serializers.Serializer):
    event_type = serializers.CharField(max_length=100)
    data = serializers.DictField()
