import uuid
from django.db import models
from django.utils import timezone


def _uuid_str():
    return str(uuid.uuid4())


class NotificationMessages(models.Model):
    message_id = models.TextField(primary_key=True, default=_uuid_str)
    account = models.ForeignKey(
        'authentication.Accounts', on_delete=models.CASCADE, db_column='account_id'
    )
    order = models.ForeignKey(
        'order.Orders', on_delete=models.SET_NULL, db_column='order_id', null=True, blank=True
    )
    subject = models.TextField(blank=True, null=True)
    body = models.TextField(blank=True, null=True)
    delivery_channel = models.TextField()
    delivery_status = models.TextField()
    created_at = models.DateTimeField(default=timezone.now)
    sent_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = 'notification_messages'

    def __str__(self):
        return f"Notification {self.message_id} -> {self.account_id}"
