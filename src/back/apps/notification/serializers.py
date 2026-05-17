from rest_framework import serializers
from django.utils import timezone

from .models import NotificationMessages


class NotificationMessageSerializer(serializers.ModelSerializer):
    order_id = serializers.SerializerMethodField()
    created_at = serializers.SerializerMethodField()
    sent_at = serializers.SerializerMethodField()

    class Meta:
        model = NotificationMessages
        fields = [
            'message_id',
            'subject',
            'body',
            'delivery_channel',
            'delivery_status',
            'created_at',
            'sent_at',
            'order_id',
        ]

    def _fmt_dt(self, dt):
        if dt is None:
            return None
        # Ensure UTC Z format
        utc = dt.astimezone(timezone.UTC)
        return utc.strftime('%Y-%m-%dT%H:%M:%SZ')

    def get_order_id(self, obj):
        return getattr(obj.order, 'order_id', None)

    def get_created_at(self, obj):
        return self._fmt_dt(obj.created_at)

    def get_sent_at(self, obj):
        return self._fmt_dt(obj.sent_at)
