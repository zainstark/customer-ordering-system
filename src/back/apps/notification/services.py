import uuid
from dataclasses import dataclass
from datetime import datetime
from typing import List, Tuple

from django.db.models import QuerySet
from django.utils import timezone

from .models import NotificationMessages


IN_APP_CHANNEL = 'IN_APP'
PENDING_STATUS = 'PENDING'
DELIVERED_STATUS = 'DELIVERED'


@dataclass(frozen=True)
class OrderNotificationTemplate:
    subject: str
    body: str


_ORDER_STATUS_MESSAGES = {
    'PENDING': OrderNotificationTemplate(
        subject='Order Placed',
        body='Your order has been placed successfully.',
    ),
    'CONFIRMED': OrderNotificationTemplate(
        subject='Order Confirmed',
        body='Your order has been confirmed by the restaurant.',
    ),
    'PREPARING': OrderNotificationTemplate(
        subject='Order Preparing',
        body='Your order is now being prepared.',
    ),
    'READY': OrderNotificationTemplate(
        subject='Order Ready',
        body='Your order is ready for pickup or delivery.',
    ),
    'OUT_FOR_DELIVERY': OrderNotificationTemplate(
        subject='Order Out for Delivery',
        body='Your order is on the way.',
    ),
    'DELIVERED': OrderNotificationTemplate(
        subject='Order Delivered',
        body='Your order has been delivered.',
    ),
    'CANCELLED': OrderNotificationTemplate(
        subject='Order Cancelled',
        body='Your order was cancelled.',
    ),
    'REFUNDED': OrderNotificationTemplate(
        subject='Order Refunded',
        body='Your order has been refunded.',
    ),
    'FAILED': OrderNotificationTemplate(
        subject='Order Failed',
        body='We could not complete your order.',
    ),
}


class NotificationService:
    @staticmethod
    def create_notification(
        account_id: str,
        subject: str,
        body: str,
        delivery_channel: str = 'IN_APP',
        order_id: str | None = None,
    ) -> NotificationMessages:
        message_id = str(uuid.uuid4())
        kwargs = dict(
            message_id=message_id,
            subject=subject[:255],
            body=body[:1000],
            delivery_channel=delivery_channel,
            delivery_status=PENDING_STATUS,
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )
        if order_id:
            kwargs['order_id'] = order_id

        # Create via model manager; account must exist
        notif = NotificationMessages.objects.create(
            account_id=account_id,
            **kwargs,
        )
        return notif

    @staticmethod
    def notify_order_placed(order) -> NotificationMessages:
        template = _ORDER_STATUS_MESSAGES['PENDING']
        return NotificationService.create_notification(
            account_id=order.account_id,
            subject=template.subject,
            body=f'{template.body} Order #{order.order_id}.',
            delivery_channel=IN_APP_CHANNEL,
            order_id=order.order_id,
        )

    @staticmethod
    def notify_order_status_changed(order, previous_status: str, new_status: str) -> NotificationMessages | None:
        if previous_status == new_status:
            return None

        template = _ORDER_STATUS_MESSAGES.get(new_status)
        if template is None:
            return None

        body = template.body
        if order.order_id:
            body = f'{body} Order #{order.order_id}.'

        return NotificationService.create_notification(
            account_id=order.account_id,
            subject=template.subject,
            body=body,
            delivery_channel=IN_APP_CHANNEL,
            order_id=order.order_id,
        )

    @staticmethod
    def get_notifications(account_id: str, page: int = 1, limit: int = 10) -> Tuple[List[NotificationMessages], int, bool]:
        if page < 1:
            page = 1
        if limit < 1:
            limit = 10

        qs = NotificationMessages.objects.filter(
            account_id=account_id, delivery_channel=IN_APP_CHANNEL
        ).order_by('-created_at')
        total = qs.count()
        start = (page - 1) * limit
        end = start + limit
        items = list(qs[start:end])
        has_next = end < total
        return items, total, has_next

    @staticmethod
    def get_unread_count(account_id: str) -> int:
        return NotificationMessages.objects.filter(
            account_id=account_id, delivery_channel=IN_APP_CHANNEL, delivery_status=PENDING_STATUS
        ).count()

    @staticmethod
    def mark_as_read(message_id: str, account_id: str):
        try:
            notif = NotificationMessages.objects.get(message_id=message_id, account_id=account_id)
        except NotificationMessages.DoesNotExist:
            return None

        if notif.delivery_status != DELIVERED_STATUS:
            notif.delivery_status = DELIVERED_STATUS
            notif.save(update_fields=['delivery_status'])
        return notif

    @staticmethod
    def mark_all_as_read(account_id: str) -> int:
        qs = NotificationMessages.objects.filter(
            account_id=account_id,
            delivery_channel=IN_APP_CHANNEL,
            delivery_status=PENDING_STATUS,
        )
        updated = qs.update(delivery_status=DELIVERED_STATUS)
        return updated
