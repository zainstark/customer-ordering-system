import uuid
from django.db import models

class OrderStatus(models.TextChoices):
    PENDING = 'PENDING', 'Pending'
    CONFIRMED = 'CONFIRMED', 'Confirmed'
    PREPARING = 'PREPARING', 'Preparing'
    READY = 'READY', 'Ready'
    OUT_FOR_DELIVERY = 'OUT_FOR_DELIVERY', 'Out for Delivery'
    DELIVERED = 'DELIVERED', 'Delivered'

class Order(models.Model):
    order_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    account_id = models.CharField(max_length=255) 
    total_amount = models.IntegerField(help_text="Stored in cents")
    order_status = models.CharField(max_length=50, choices=OrderStatus.choices, default=OrderStatus.PENDING)
    placed_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    menu_item_id = models.CharField(max_length=255)
    item_name_snapshot = models.CharField(max_length=255)
    unit_price_snapshot = models.IntegerField()
    quantity = models.PositiveIntegerField()
    line_total = models.IntegerField()

class OrderStatusHistory(models.Model):
    history_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, related_name='status_history', on_delete=models.CASCADE)
    order_status = models.CharField(max_length=50, choices=OrderStatus.choices)
    note = models.TextField(blank=True, null=True)
    changed_at = models.DateTimeField(auto_now_add=True)