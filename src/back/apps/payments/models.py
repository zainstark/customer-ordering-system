import uuid

from django.db import models


def _uuid_str():
    return str(uuid.uuid4())


class Payment(models.Model):
    payment_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    order = models.ForeignKey('order.Orders', models.CASCADE, related_name='payments')
    payment_method = models.TextField()
    payment_status = models.TextField()
    amount = models.IntegerField()
    currency = models.CharField(max_length=10, default='usd')
    payment_intent_id = models.TextField(blank=True, null=True)
    client_secret = models.TextField(blank=True, null=True)
    idempotency_key = models.TextField(blank=True, null=True)
    checkout_url = models.TextField(blank=True, null=True)
    gateway_reference = models.TextField(blank=True, null=True)
    attempt_count = models.IntegerField(default=0)
    initiated_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = 'payments'


class PaymentTransaction(models.Model):
    transaction_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    payment = models.ForeignKey('payments.Payment', models.CASCADE, related_name='transactions')
    gateway_reference = models.TextField(blank=True, null=True)
    authorization_code = models.TextField(blank=True, null=True)
    processed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'transactions'
