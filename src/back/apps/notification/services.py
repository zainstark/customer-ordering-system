from typing import List, Tuple
from django.utils import timezone
from django.db.models import QuerySet

from .models import NotificationMessages
import uuid


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
            subject=subject,
            body=body,
            delivery_channel=delivery_channel,
            delivery_status='PENDING',
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
    def get_notifications(account_id: str, page: int = 1, limit: int = 10) -> Tuple[List[NotificationMessages], int, bool]:
        qs = NotificationMessages.objects.filter(
            account_id=account_id, delivery_channel='IN_APP'
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
            account_id=account_id, delivery_channel='IN_APP', delivery_status='PENDING'
        ).count()

    @staticmethod
    def mark_as_read(message_id: str, account_id: str):
        try:
            notif = NotificationMessages.objects.get(message_id=message_id, account_id=account_id)
        except NotificationMessages.DoesNotExist:
            return None

        notif.delivery_status = 'DELIVERED'
        notif.save()
        return notif

    @staticmethod
    def mark_all_as_read(account_id: str) -> int:
        qs = NotificationMessages.objects.filter(account_id=account_id, delivery_channel='IN_APP', delivery_status='PENDING')
        updated = qs.update(delivery_status='DELIVERED')
        return updated
