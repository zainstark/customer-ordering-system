import uuid

from django.db import models
from django.utils import timezone


def _uuid_str():
    return str(uuid.uuid4())


class Payment(models.Model):
    payment_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    order = models.ForeignKey('order.Orders', models.CASCADE, related_name='payments')
    payment_method = models.TextField()
    payment_status = models.TextField()
    amount = models.IntegerField()
    checkout_url = models.TextField(blank=True, null=True)
    gateway_reference = models.TextField(blank=True, null=True)
    attempt_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'payments'


class PaymentTransaction(models.Model):
    transaction_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    payment = models.ForeignKey('payments.Payment', models.CASCADE, related_name='transactions')
    gateway_payload = models.TextField(blank=True, null=True)
    transaction_status = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'payment_transactions'
