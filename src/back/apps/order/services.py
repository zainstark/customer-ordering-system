"""
Order service layer.

All business logic for placing and querying orders lives here.
Views must not contain business logic — they call this module and
translate the result into an HTTP response.

Public API
----------
OrderService.place_order(account_id, address)
    -> Tuple[Optional[Order], Optional[str]]
    Returns (order, None) on success, (None, error_message) on failure.

OrderService.get_orders_for_account(account_id)
    -> QuerySet[Order]
    Returns the account's orders newest-first, with items pre-fetched.
"""

from __future__ import annotations

from datetime import timedelta
from typing import Optional, Tuple

from django.db import transaction
from django.db.models import Prefetch, QuerySet
from django.utils import timezone

from apps.cart.models import Cart, CartItem
from apps.cart.services import CartService
from apps.order.models import Orders as Order, OrderItems


# How long a PENDING/CONFIRMED order blocks a new placement attempt.
# Protects against EC-UC4-02 (double-click / network retry).
_IDEMPOTENCY_WINDOW_SECONDS = 30


class OrderService:

    # ------------------------------------------------------------------
    # Public methods
    # ------------------------------------------------------------------

    @staticmethod
    def place_order(
        account_id: str,
        address: str,
    ) -> Tuple[Optional[Order], Optional[str]]:
        """
        Convert the account's current cart into a confirmed Order.

        Steps (all inside a single atomic transaction so any failure
        rolls back every DB write made in this call):

          1. Idempotency guard — return the existing order if a recent
             PENDING/CONFIRMED order already exists for this account.
          2. Fetch the cart — return an error if none exists.
          3. Validate the cart is not empty (EC-UC4-01).
          4. Load every cart item's live MenuItem from the DB.
          5. Validate every item is still available (EC-UC3-01).
          6. Re-price from the DB — never trust the cart snapshot
             (EC-UC4-04).
          7. Create the Order row.
          8. Create one OrderItems row per cart item.
          9. Clear the cart.

        Returns:
            (Order, None)          on success
            (None, error_message)  on any validation failure
        """
        # Step 1 — idempotency: if a very recent order already exists,
        # return it instead of creating a duplicate.
        recent_order = OrderService._find_recent_pending_order(account_id)
        if recent_order is not None:
            return recent_order, None

        # Steps 2-9 are wrapped in a single atomic block.
        # If anything raises an exception after the Order row has been
        # written, the entire transaction is rolled back automatically.
        try:
            with transaction.atomic():
                # Step 2 — fetch cart
                try:
                    cart = Cart.objects.get(account_id=account_id)
                except Cart.DoesNotExist:
                    return None, "No cart found for this account."

                # Step 3 — empty cart check
                cart_items = list(
                    CartItem.objects.select_related("menu_item").filter(cart=cart)
                )
                if not cart_items:
                    return None, "Cannot place an order with an empty cart."

                # Steps 4 & 5 — availability validation using live DB data.
                # We read menu_item via the FK that was already selected above,
                # so no extra queries are needed per item.
                for cart_item in cart_items:
                    menu_item = cart_item.menu_item
                    if not menu_item.available:
                        # Raise so the atomic block rolls back any partial writes.
                        raise _ValidationError(
                            f"Item '{menu_item.name}' is no longer available."
                        )

                # Step 6 — compute total from live DB prices, never from
                # cart snapshots (defends against EC-UC4-04).
                total_amount = sum(
                    cart_item.menu_item.price_penny * cart_item.quantity
                    for cart_item in cart_items
                )

                # Step 7 — create the Order row.
                order = Order.objects.create(
                    account_id=account_id,
                    total_amount=total_amount,
                    address=address,
                    order_status="PENDING",
                    placed_at=timezone.now(),
                )

                # Step 8 — create one OrderItems per cart item, snapshotting
                # the current name, description, and live price.
                for cart_item in cart_items:
                    menu_item = cart_item.menu_item
                    OrderItems.objects.create(
                        order=order,
                        menu_item_id=menu_item.menu_item_id,
                        item_name_snapshot=menu_item.name,
                        item_description_snapshot=menu_item.description or "",
                        unit_price_snapshot=menu_item.price_penny,
                        quantity=cart_item.quantity,
                    )

                # Step 9 — clear the cart only after everything else has
                # succeeded. CartService.clear_cart is already tested and
                # handles its own DB writes safely inside this outer atomic block.
                CartService.clear_cart(cart.cart_id)

                return order, None

        except _ValidationError as exc:
            # Translate the internal sentinel back into the (None, str) contract.
            return None, str(exc)

    @staticmethod
    def get_orders_for_account(account_id: str) -> QuerySet:
        """
        Return all orders for the given account, newest first.

        Items are pre-fetched in a single extra query so serializers
        can iterate order.items.all() without hitting the DB per order.
        """
        return (
            Order.objects.filter(account_id=account_id)
            .prefetch_related(
                Prefetch("items", queryset=OrderItems.objects.order_by("created_at"))
            )
            .order_by("-placed_at")
        )

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _find_recent_pending_order(account_id: str) -> Optional[Order]:
        """
        Return the most recent PENDING or CONFIRMED order placed by this
        account within the idempotency window, or None.

        This prevents duplicate orders from double-clicks and network
        retries (EC-UC4-02).
        """
        cutoff = timezone.now() - timedelta(seconds=_IDEMPOTENCY_WINDOW_SECONDS)
        return (
            Order.objects.filter(
                account_id=account_id,
                order_status__in=["PENDING", "CONFIRMED"],
                placed_at__gte=cutoff,
            )
            .order_by("-placed_at")
            .first()
        )


# ---------------------------------------------------------------------------
# Internal sentinel — never leaks outside this module
# ---------------------------------------------------------------------------

class _ValidationError(Exception):
    """
    Raised inside the atomic block to trigger a rollback and carry the
    user-facing error message back to place_order's except clause.

    Using a dedicated exception instead of returning early means the
    transaction.atomic() context manager sees an exception and rolls
    back any DB writes made before the validation failure was detected.
    This is what makes the atomicity test pass.
    """