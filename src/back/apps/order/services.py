from django.db import transaction
from django.core.cache import cache
from rest_framework.exceptions import ValidationError
from apps.order.models import Order, OrderItem, OrderStatus

# Note: In a fully implemented system, these would be imported from your 
# specific cart and menu Django apps or fetched via gRPC/internal API.
# from cart.models import Cart
# from menu.models import MenuItem

class OrderService:

    @classmethod
    def create_order(cls, account_id: str, idempotency_key: str) -> tuple[Order, bool]:
        """
        Creates a new order from the customer's active cart.
        Returns a tuple: (Order object, created boolean).
        """
        
        # 1. Idempotency Check (EC-UC4-02)
        if idempotency_key:
            cache_key = f"order_idempotency_{account_id}_{idempotency_key}"
            existing_order_id = cache.get(cache_key)
            if existing_order_id:
                # Return the existing order and flag created=False
                return Order.objects.get(order_id=existing_order_id), False

        # 2. Begin Atomic Transaction (EC-UC4-05)
        with transaction.atomic():
            
            # Fetch Cart Data
            cart, cart_items = cls._get_cart_and_items(account_id)

            # Validation: Empty Cart (EC-UC4-01)
            if not cart_items:
                raise ValidationError("Order cannot be placed with an empty cart.")

            # Fetch Menu Items with a Row-Level Lock to prevent race conditions (EC-UC4-03)
            menu_item_ids = [item.menu_item_id for item in cart_items]
            menu_item_map = cls._get_menu_items_map(menu_item_ids)

            total_amount = 0
            order_items_data = []

            # 3. Item-by-Item Validation and Snapshot Creation
            for cart_item in cart_items:
                menu_item = menu_item_map.get(cart_item.menu_item_id)

                # Validation: Item Availability (UC4 Alt Flow)
                if not menu_item or not menu_item.available:
                    raise ValidationError(f"Item {cart_item.menu_item_id} is currently out of stock.")

                # Validation: Price Change Alert (EC-UC3-03 / UC4 Alt Flow)
                if cart_item.unit_price_snapshot != menu_item.price_penny:
                    raise ValidationError(
                        f"Price for {cart_item.menu_item_id} has changed. Please review your cart."
                    )

                # Server-Side Price Calculation (EC-UC4-04: Prevents Client Tampering)
                unit_price = menu_item.price_penny
                line_total = unit_price * cart_item.quantity
                total_amount += line_total

                # Prepare Immutable Order Item Snapshot
                order_items_data.append(OrderItem(
                    menu_item_id=cart_item.menu_item_id,
                    item_name_snapshot=menu_item.name,
                    item_description_snapshot=menu_item.description,
                    unit_price_snapshot=unit_price,
                    quantity=cart_item.quantity,
                    line_total=line_total
                ))

            # 4. Database Persistence
            order = Order.objects.create(
                account_id=account_id,
                total_amount=total_amount,
                order_status=OrderStatus.PENDING
            )

            for item in order_items_data:
                item.order = order
            OrderItem.objects.bulk_create(order_items_data)

            # 5. Clear the Cart (Deactivate it as it is now an Order)
            if cart:
                cart.status = 'COMPLETED'
                cart.save()

            # 6. Cache the Idempotency Key for 24 hours
            if idempotency_key:
                cache.set(cache_key, order.order_id, timeout=86400)

            return order, True

    # =========================================================================
    # Data Fetching Helpers (Isolated to allow easy mocking in tests.py)
    # =========================================================================

    @classmethod
    def _get_cart_and_items(cls, account_id: str):
        """
        Fetches the active cart and its items.
        Isolated to allow patching during testing without requiring the Cart module.
        """
        # Implementation depends on Cart module structure. Example:
        # cart = Cart.objects.filter(account_id=account_id, status='ACTIVE').first()
        # if not cart:
        #     return None, []
        # return cart, list(cart.items.all())
        pass 

    @classmethod
    def _get_menu_items_map(cls, menu_item_ids: list):
        """
        Fetches menu items using select_for_update() to lock rows for inventory safety.
        Returns a dictionary mapping menu_item_id -> MenuItem object.
        """
        # Implementation depends on Menu module structure. Example:
        # items = MenuItem.objects.select_for_update().filter(menu_item_id__in=menu_item_ids)
        # return {item.menu_item_id: item for item in items}
        pass