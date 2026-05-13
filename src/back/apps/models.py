from django.db import models
from django.conf import settings

class Order(models.Model):
    # Based on ERD: ORDERS table
    account_id = models.IntegerField()  # Stub for User reference
    order_status = models.CharField(max_length=50, default='PENDING')
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    placed_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class OrderItem(models.Model):
    # Based on ERD: ORDER_ITEMS table
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    menu_item_id = models.CharField(max_length=50) # External reference
    item_name_snapshot = models.CharField(max_length=255) # Snapshot requirement
    unit_price_snapshot = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.IntegerField()
    line_total = models.DecimalField(max_digits=10, decimal_places=2)