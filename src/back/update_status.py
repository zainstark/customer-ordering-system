import os
import sys
import django
from django.utils import timezone

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from apps.order.models import Orders, OrderStatusHistory

def main():
    if len(sys.argv) != 3:
        print("Usage: python update_status.py <order_id> <STATUS>")
        print("Valid statuses: PENDING, CONFIRMED, PREPARING, READY, OUT_FOR_DELIVERY, DELIVERED, CANCELLED, FAILED")
        sys.exit(1)

    order_id = sys.argv[1]
    new_status = sys.argv[2].upper()

    valid_statuses = ["PENDING", "CONFIRMED", "PREPARING", "READY", "OUT_FOR_DELIVERY", "DELIVERED", "CANCELLED", "FAILED"]
    if new_status not in valid_statuses:
        print(f"❌ Error: Invalid status '{new_status}'.")
        print(f"Valid statuses: {', '.join(valid_statuses)}")
        sys.exit(1)

    try:
        order = Orders.objects.get(order_id=order_id)
        order.order_status = new_status
        order.save(update_fields=['order_status'])
        
        OrderStatusHistory.objects.create(
            order=order,
            order_status=new_status,
            changed_at=timezone.now()
        )
        print(f"✅ Successfully updated order {order_id} to {new_status}")
    except Orders.DoesNotExist:
        print(f"❌ Error: Order {order_id} not found.")

if __name__ == "__main__":
    main()
