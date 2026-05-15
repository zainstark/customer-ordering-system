from django.db import transaction
from .models import Order, OrderItem, OrderStatusHistory

class PriceMismatchError(Exception): pass
class ItemUnavailableError(Exception): pass

class OrderService:
    def create_order(self, account_id, cart_items, expected_total_cents):
        if not cart_items:
            raise ValueError("Order cannot be placed with an empty cart.")

        calculated_total = sum(item['price_cents'] * item['quantity'] for item in cart_items)
        if calculated_total != expected_total_cents:
            raise PriceMismatchError("Price mismatch detected. Cart prices may have changed.")

        with transaction.atomic():
            order = Order.objects.create(
                account_id=account_id,
                total_amount=calculated_total,
                order_status='PENDING'
            )

            for item in cart_items:
                OrderItem.objects.create(
                    order=order,
                    menu_item_id=item['id'],
                    item_name_snapshot=item['name'],
                    unit_price_snapshot=item['price_cents'],
                    quantity=item['quantity'],
                    line_total=item['price_cents'] * item['quantity']
                )

            OrderStatusHistory.objects.create(
                order=order, order_status='PENDING', note="Order placed."
            )

            return order