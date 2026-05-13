from django.db import transaction
from apps.models import Order, OrderItem

class PriceMismatchError(Exception): pass

class OrderService:
    def create_order(self, user_id, cart_items, expected_total):
        # 1. Edge Case Cage: Check empty cart
        if not cart_items:
            raise ValueError("Order cannot be placed with an empty cart")

        # 2. Server-side total calculation
        calculated_total = sum(item['price'] * item['quantity'] for item in cart_items)
        if abs(float(calculated_total) - float(expected_total)) > 0.01:
            raise PriceMismatchError("Price mismatch detected.")

        # 3. Padlock: Atomic Transaction for Inventory Lock
        with transaction.atomic():
            # (In a real system, you would use select_for_update() on MenuItem here)
            
            # 4. Create Order record
            order = Order.objects.create(
                account_id=user_id,
                total_amount=calculated_total
            )

            # 5. Padlock: Snapshot creation for data integrity
            for item in cart_items:
                OrderItem.objects.create(
                    order=order,
                    menu_item_id=item['id'],
                    item_name_snapshot=item['name'], # Critical Snapshot
                    unit_price_snapshot=item['price'],
                    quantity=item['quantity'],
                    line_total=item['price'] * item['quantity']
                )
            
            return order