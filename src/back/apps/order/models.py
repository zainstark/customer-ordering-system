import uuid
from django.db import models
from django.db.models import CheckConstraint, Q
from django.utils.translation import gettext_lazy as _

class OrderStatus(models.TextChoices):
    PENDING = 'PENDING', _('Pending')
    CONFIRMED = 'CONFIRMED', _('Confirmed')
    PREPARING = 'PREPARING', _('Preparing')
    READY = 'READY', _('Ready')
    OUT_FOR_DELIVERY = 'OUT_FOR_DELIVERY', _('Out for Delivery')
    DELIVERED = 'DELIVERED', _('Delivered')
    CANCELLED = 'CANCELLED', _('Cancelled')
    REFUNDED = 'REFUNDED', _('Refunded')
    FAILED = 'FAILED', _('Failed')

class PaymentMethod(models.TextChoices):
    CASH = 'CASH', _('Cash')
    CARD = 'CARD', _('Card')

class PaymentStatus(models.TextChoices):
    PENDING = 'PENDING', _('Pending')
    AUTHORIZED = 'AUTHORIZED', _('Authorized')
    COMPLETED = 'COMPLETED', _('Completed')
    FAILED = 'FAILED', _('Failed')
    REFUNDED = 'REFUNDED', _('Refunded')
    CANCELLED = 'CANCELLED', _('Cancelled')

class Order(models.Model):
    order_id = models.CharField(max_length=255, primary_key=True, default=uuid.uuid4, editable=False)
    # Assuming cross-app relationships use strings to decouple domains, or this could be a ForeignKey if apps are monolithic.
    account_id = models.CharField(max_length=255, db_index=True) 
    total_amount = models.IntegerField()  # Stored in pennies as per standard financial practices
    placed_at = models.DateTimeField(auto_now_add=True)
    order_status = models.CharField(max_length=50, choices=OrderStatus.choices, default=OrderStatus.PENDING)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'orders'
        indexes = [
            models.Index(fields=['account_id'], name='idx_orders_account_id'),
        ]

    def __str__(self):
        return f"Order {self.order_id} - {self.order_status}"

class OrderItem(models.Model):
    order_item_id = models.CharField(max_length=255, primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    menu_item_id = models.CharField(max_length=255, db_index=True)
    item_name_snapshot = models.CharField(max_length=255)
    item_description_snapshot = models.TextField(null=True, blank=True)
    unit_price_snapshot = models.IntegerField()
    quantity = models.IntegerField()
    line_total = models.IntegerField()

    class Meta:
        db_table = 'order_items'
        indexes = [
            models.Index(fields=['order_id'], name='idx_order_items_order_id'),
            models.Index(fields=['menu_item_id'], name='idx_order_items_menu_item_id'),
        ]
        constraints = [
            CheckConstraint(condition=Q(quantity__gt=0), name='check_quantity_positive')
        ]

    def __str__(self):
        return f"{self.quantity}x {self.item_name_snapshot} (Order: {self.order_id})"

class OrderStatusHistory(models.Model):
    history_id = models.CharField(max_length=255, primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='status_history')
    order_status = models.CharField(max_length=50, choices=OrderStatus.choices)
    note = models.TextField(null=True, blank=True)
    changed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'order_status_history'
        indexes = [
            models.Index(fields=['order_id'], name='order_hist_idx'),
        ]

    def __str__(self):
        return f"{self.order_id} -> {self.order_status} at {self.changed_at}"

class Payment(models.Model):
    payment_id = models.CharField(max_length=255, primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='payments')
    amount = models.IntegerField()
    initiated_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)
    payment_method = models.CharField(max_length=50, choices=PaymentMethod.choices)
    payment_status = models.CharField(max_length=50, choices=PaymentStatus.choices, default=PaymentStatus.PENDING)

    class Meta:
        db_table = 'payments'
        indexes = [
            models.Index(fields=['order_id'], name='idx_payments_order_id'),
        ]

    def __str__(self):
        return f"Payment {self.payment_id} for Order {self.order_id} - {self.payment_status}"

class Transaction(models.Model):
    transaction_id = models.CharField(max_length=255, primary_key=True, default=uuid.uuid4, editable=False)
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name='transactions')
    gateway_reference = models.CharField(max_length=255, null=True, blank=True)
    authorization_code = models.CharField(max_length=255, null=True, blank=True)
    processed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'transactions'
        indexes = [
            models.Index(fields=['payment_id'], name='idx_transactions_payment_id'),
        ]

    def __str__(self):
        return f"Transaction {self.transaction_id} (Auth: {self.authorization_code})"