"""Cart models for the Django backend."""

import uuid

from django.core.validators import MinValueValidator
from django.db import models


def generate_uuid():
    return str(uuid.uuid4())


class Cart(models.Model):
    CART_STATUS_CHOICES = [
        ('ACTIVE', 'Active'),
        ('ABANDONED', 'Abandoned'),
        ('CONVERTED', 'Converted to Order'),
    ]

    cart_id = models.CharField(
        max_length=36,
        primary_key=True,
        default=generate_uuid,
        editable=False,
    )
    account_id = models.CharField(
        max_length=36,
        unique=True,
        db_index=True,
        help_text='Foreign key to customer_accounts.account_id',
    )
    status = models.CharField(
        max_length=20,
        choices=CART_STATUS_CHOICES,
        default='ACTIVE',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'carts'
        verbose_name = 'Shopping Cart'
        verbose_name_plural = 'Shopping Carts'
        ordering = ['-updated_at']

    def __str__(self):
        return f"Cart {self.cart_id[:8]}... for {self.account_id[:8]}..."

    def get_cart_total(self):
        return sum(item.line_total for item in self.cartitem_set.all()) or 0

    def get_item_count(self):
        return sum(item.quantity for item in self.cartitem_set.all()) or 0


class CartItem(models.Model):
    cart_item_id = models.CharField(
        max_length=36,
        primary_key=True,
        default=generate_uuid,
        editable=False,
    )
    cart = models.ForeignKey(
        Cart,
        on_delete=models.CASCADE,
        db_column='cart_id',
    )
    menu_item_id = models.CharField(
        max_length=36,
        db_index=True,
        help_text='Foreign key to menu_items.menu_item_id',
    )
    quantity = models.PositiveIntegerField(
        validators=[MinValueValidator(1)],
        help_text='Quantity must be greater than 0',
    )
    unit_price_snapshot = models.PositiveIntegerField(
        help_text='Price in pennies at time of addition (snapshot)',
    )
    line_total = models.PositiveIntegerField(
        help_text='quantity * unit_price_snapshot (in pennies)',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'cart_items'
        verbose_name = 'Cart Item'
        verbose_name_plural = 'Cart Items'
        unique_together = [('cart', 'menu_item_id')]
        ordering = ['created_at']

    def __str__(self):
        return f"CartItem {self.cart_item_id[:8]}... (qty: {self.quantity})"

    def calculate_line_total(self):
        return self.quantity * self.unit_price_snapshot

    def save(self, *args, **kwargs):
        self.line_total = self.calculate_line_total()
        super().save(*args, **kwargs)
