import uuid

from django.db import models
from django.utils import timezone


def _uuid_str():
    return str(uuid.uuid4())


class OrderItems(models.Model):
    order_item_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    order = models.ForeignKey('Orders', models.CASCADE, related_name='items')
    menu_item = models.ForeignKey("menu.MenuItem", models.DO_NOTHING)
    item_name_snapshot = models.TextField()
    item_description_snapshot = models.TextField(blank=True, null=True)
    unit_price_snapshot = models.IntegerField()
    quantity = models.IntegerField()
    line_total = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'order_items'

    def save(self, *args, **kwargs):
        # Auto-compute line_total if not explicitly set
        if not self.line_total:
            self.line_total = self.unit_price_snapshot * self.quantity
        super().save(*args, **kwargs)


class OrderStatusHistory(models.Model):
    history_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    order = models.ForeignKey('Orders', models.DO_NOTHING)
    order_status = models.TextField()
    note = models.TextField(blank=True, null=True)
    changed_at = models.DateTimeField()

    class Meta:
        db_table = 'order_status_history'


class Orders(models.Model):
    order_id = models.TextField(primary_key=True, blank=True, null=False, default=_uuid_str)
    account = models.ForeignKey("authentication.Accounts", models.DO_NOTHING)
    total_amount = models.IntegerField()
    placed_at = models.DateTimeField()
    order_status = models.TextField()
    confirmed_at = models.DateTimeField(blank=True, null=True)
    updated_at = models.DateTimeField(default=timezone.now)
    address = models.TextField()

    class Meta:
        db_table = 'orders'
