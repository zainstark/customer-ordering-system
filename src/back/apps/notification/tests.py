"""
Comprehensive tests for Notification feature — TDD approach.

Tests define:
  1. Model behavior (creation, fields, defaults)
  2. Serializer output format (matches API contract)
  3. Service business logic (create, paginate, mark as read)
  4. API endpoint behavior (auth, validation, responses)

Run with: python manage.py test apps.notification
"""

import uuid
from datetime import datetime
from django.db import connection
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APITestCase

from apps.authentication.models import Accounts
from apps.order.models import Orders

from apps.notification.models import NotificationMessages as NotificationMessage
from apps.notification.services import NotificationService
from apps.notification.serializers import NotificationMessageSerializer


def _ensure_accounts_table():
    table_name = Accounts._meta.db_table
    existing_tables = connection.introspection.table_names()
    if table_name in existing_tables:
        return

    with connection.cursor() as cursor:
        cursor.execute(
            """
            CREATE TABLE accounts (
                account_id TEXT PRIMARY KEY NOT NULL,
                display_name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                role TEXT NOT NULL,
                password_hash TEXT NOT NULL,
                phone_number TEXT,
                active BOOL NOT NULL,
                created_at DATETIME NOT NULL,
                updated_at DATETIME NOT NULL
            )
            """
        )


# ============================================================================
# MODEL TESTS
# ============================================================================


class NotificationMessageModelTestCase(TestCase):
    """Test NotificationMessage model creation, fields, and defaults."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        """Create test account for notifications."""
        self.account = Accounts.objects.create(
            account_id=str(uuid.uuid4()),
            display_name="Test User",
            email="test@example.com",
            role="CUSTOMER",
            password_hash="hashed_password",
            active=True,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )

    def test_create_notification_with_all_fields(self):
        """Test creating notification with all fields."""
        message_id = str(uuid.uuid4())
        notification = NotificationMessage.objects.create(
            message_id=message_id,
            account=self.account,
            subject="Test Subject",
            body="Test body content",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )

        self.assertEqual(notification.message_id, message_id)
        self.assertEqual(notification.account, self.account)
        self.assertEqual(notification.subject, "Test Subject")
        self.assertEqual(notification.body, "Test body content")
        self.assertEqual(notification.delivery_channel, "IN_APP")
        self.assertEqual(notification.delivery_status, "PENDING")
        self.assertIsNone(getattr(notification, 'order', None))

    def test_create_notification_with_order(self):
        """Test creating notification linked to an order."""
        order = Orders.objects.create(
            order_id=str(uuid.uuid4()),
            account=self.account,
            total_amount=10000,
            placed_at=timezone.now(),
            order_status="PENDING",
            address="123 Main St",
            updated_at=timezone.now(),
        )

        notification = NotificationMessage.objects.create(
            message_id=str(uuid.uuid4()),
            account=self.account,
            order=order,
            subject="Order Placed",
            body="Your order has been placed",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )

        self.assertEqual(notification.order, order)

    def test_notification_sent_at_nullable(self):
        """Test that sent_at can be null."""
        notification = NotificationMessage.objects.create(
            message_id=str(uuid.uuid4()),
            account=self.account,
            subject="Test",
            body="Test body",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=None,
        )

        self.assertIsNone(notification.sent_at)

    def test_notification_order_nullable(self):
        """Test that order can be null (promotional notifications)."""
        notification = NotificationMessage.objects.create(
            message_id=str(uuid.uuid4()),
            account=self.account,
            subject="Promotion",
            body="Special offer",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )

        self.assertIsNone(getattr(notification, 'order', None))


# ============================================================================
# SERIALIZER TESTS
# ============================================================================


class NotificationMessageSerializerTestCase(TestCase):
    """Test NotificationMessageSerializer output format."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        """Create test account and notifications."""
        self.account = Accounts.objects.create(
            account_id=str(uuid.uuid4()),
            display_name="Test User",
            email="test@example.com",
            role="CUSTOMER",
            password_hash="hashed_password",
            active=True,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )

    def test_serializer_output_format(self):
        """Test serializer produces correct JSON structure."""
        now = timezone.now()
        notification = NotificationMessage.objects.create(
            message_id="msg_001",
            account=self.account,
            subject="Order Delivered",
            body="Your order has been delivered",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=now,
            sent_at=now,
        )

        serializer = NotificationMessageSerializer(notification)
        data = serializer.data

        # Verify field names match API contract (snake_case)
        self.assertIn("message_id", data)
        self.assertIn("subject", data)
        self.assertIn("body", data)
        self.assertIn("delivery_channel", data)
        self.assertIn("delivery_status", data)
        self.assertIn("created_at", data)
        self.assertIn("sent_at", data)
        self.assertIn("order_id", data)

    def test_serializer_timestamp_iso8601_format(self):
        """Test timestamps are ISO 8601 format with UTC."""
        now = timezone.now()
        notification = NotificationMessage.objects.create(
            message_id="msg_001",
            account=self.account,
            subject="Test",
            body="Test body",
            delivery_channel="IN_APP",
            delivery_status="DELIVERED",
            created_at=now,
            sent_at=now,
        )

        serializer = NotificationMessageSerializer(notification)
        data = serializer.data

        # Verify ISO 8601 format ends with Z (UTC)
        self.assertTrue(data["created_at"].endswith("Z"))
        self.assertTrue(data["sent_at"].endswith("Z"))
        # Verify it's parseable
        datetime.fromisoformat(data["created_at"].replace("Z", "+00:00"))

    def test_serializer_with_null_order_id(self):
        """Test serializer handles null order_id."""
        notification = NotificationMessage.objects.create(
            message_id="msg_002",
            account=self.account,
            subject="Promo",
            body="Special offer",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )

        serializer = NotificationMessageSerializer(notification)
        data = serializer.data

        self.assertIsNone(data["order_id"])

    def test_serializer_with_order_id(self):
        """Test serializer includes order_id when present."""
        order = Orders.objects.create(
            order_id="order_123",
            account=self.account,
            total_amount=5000,
            placed_at=timezone.now(),
            order_status="PENDING",
            address="123 Main St",
            updated_at=timezone.now(),
        )

        notification = NotificationMessage.objects.create(
            message_id="msg_003",
            account=self.account,
            order=order,
            subject="Order Status",
            body="Your order status has changed",
            delivery_channel="IN_APP",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )

        serializer = NotificationMessageSerializer(notification)
        data = serializer.data

        self.assertEqual(data["order_id"], "order_123")


# ============================================================================
# SERVICE TESTS
# ============================================================================


class NotificationServiceTestCase(TestCase):
    """Test NotificationService business logic."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        """Create test account."""
        self.account_id = str(uuid.uuid4())
        self.account = Accounts.objects.create(
            account_id=self.account_id,
            display_name="Test User",
            email="test@example.com",
            role="CUSTOMER",
            password_hash="hashed_password",
            active=True,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )

    def test_create_notification(self):
        """Test NotificationService.create_notification()."""
        notification = NotificationService.create_notification(
            account_id=self.account_id,
            subject="Order Placed",
            body="Your order #123 has been placed",
            delivery_channel="IN_APP",
            order_id=None,
        )

        # Verify notification was created
        self.assertIsNotNone(notification)
        self.assertEqual(notification.subject, "Order Placed")
        self.assertEqual(notification.body, "Your order #123 has been placed")
        self.assertEqual(notification.delivery_channel, "IN_APP")
        self.assertEqual(notification.delivery_status, "PENDING")
        self.assertEqual(notification.account_id, self.account_id)
        # Verify message_id was auto-generated
        self.assertIsNotNone(notification.message_id)

    def test_create_notification_with_order_id(self):
        """Test creating notification with order_id."""
        order = Orders.objects.create(
            order_id="order_999",
            account=self.account,
            total_amount=5000,
            placed_at=timezone.now(),
            order_status="PENDING",
            address="123 Main St",
            updated_at=timezone.now(),
        )

        notification = NotificationService.create_notification(
            account_id=self.account_id,
            subject="Order Confirmed",
            body="Order confirmed",
            order_id="order_999",
        )

        self.assertEqual(notification.order_id, "order_999")

    def test_get_notifications_paginated(self):
        """Test NotificationService.get_notifications() returns paginated list."""
        # Create 15 notifications
        for i in range(15):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Notification {i}",
                body=f"Body {i}",
            )

        # Request page 1 with limit 10
        notifications, total, has_next = NotificationService.get_notifications(
            account_id=self.account_id,
            page=1,
            limit=10,
        )

        # Verify pagination
        self.assertEqual(len(notifications), 10)
        self.assertEqual(total, 15)
        self.assertTrue(has_next)  # More pages available

        # Request page 2
        notifications_p2, total_p2, has_next_p2 = NotificationService.get_notifications(
            account_id=self.account_id,
            page=2,
            limit=10,
        )

        self.assertEqual(len(notifications_p2), 5)
        self.assertEqual(total_p2, 15)
        self.assertFalse(has_next_p2)  # No more pages

    def test_get_notifications_only_returns_in_app(self):
        """Test get_notifications filters by IN_APP channel only."""
        # Create IN_APP notification
        NotificationService.create_notification(
            account_id=self.account_id,
            subject="In-app notification",
            body="This is in-app",
            delivery_channel="IN_APP",
        )

        # Create EMAIL notification (should not be returned by service)
        NotificationMessage.objects.create(
            message_id=str(uuid.uuid4()),
            account=self.account,
            subject="Email notification",
            body="This is email",
            delivery_channel="EMAIL",
            delivery_status="PENDING",
            created_at=timezone.now(),
            sent_at=timezone.now(),
        )

        notifications, total, _ = NotificationService.get_notifications(
            account_id=self.account_id,
            page=1,
            limit=10,
        )

        # Should only return IN_APP
        self.assertEqual(len(notifications), 1)
        self.assertEqual(total, 1)
        self.assertEqual(notifications[0].delivery_channel, "IN_APP")

    def test_get_notifications_user_scoped(self):
        """Test get_notifications only returns notifications for authenticated user."""
        # Create account 2
        account2_id = str(uuid.uuid4())
        account2 = Accounts.objects.create(
            account_id=account2_id,
            display_name="Test User 2",
            email="test2@example.com",
            role="CUSTOMER",
            password_hash="hashed_password",
            active=True,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )

        # Create notifications for both accounts
        NotificationService.create_notification(
            account_id=self.account_id,
            subject="Account 1 notification",
            body="Body",
        )
        NotificationService.create_notification(
            account_id=account2_id,
            subject="Account 2 notification",
            body="Body",
        )

        # Get account 1's notifications
        notifications, total, _ = NotificationService.get_notifications(
            account_id=self.account_id,
            page=1,
            limit=10,
        )

        # Should only return 1 notification (account 1's)
        self.assertEqual(len(notifications), 1)
        self.assertEqual(total, 1)
        self.assertEqual(notifications[0].account_id, self.account_id)

    def test_get_unread_count(self):
        """Test NotificationService.get_unread_count()."""
        # Create 3 PENDING (unread) and 2 DELIVERED (read) notifications
        for i in range(3):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Unread {i}",
                body="Body",
            )

        for i in range(2):
            notification = NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Read {i}",
                body="Body",
            )
            # Mark as delivered
            notification.delivery_status = "DELIVERED"
            notification.save()

        unread_count = NotificationService.get_unread_count(
            account_id=self.account_id
        )

        # Should count only PENDING
        self.assertEqual(unread_count, 3)

    def test_mark_notification_as_read(self):
        """Test NotificationService.mark_as_read()."""
        notification = NotificationService.create_notification(
            account_id=self.account_id,
            subject="Test",
            body="Body",
        )

        # Initially PENDING
        self.assertEqual(notification.delivery_status, "PENDING")

        # Mark as read
        updated = NotificationService.mark_as_read(
            message_id=notification.message_id,
            account_id=self.account_id,
        )

        # Should be DELIVERED
        self.assertEqual(updated.delivery_status, "DELIVERED")

        # Verify in DB
        from_db = NotificationMessage.objects.get(
            message_id=notification.message_id
        )
        self.assertEqual(from_db.delivery_status, "DELIVERED")

    def test_mark_notification_as_read_wrong_user_returns_none(self):
        """Test mark_as_read prevents cross-user access."""
        notification = NotificationService.create_notification(
            account_id=self.account_id,
            subject="Test",
            body="Body",
        )

        # Try to mark as read from different account
        wrong_account_id = str(uuid.uuid4())
        updated = NotificationService.mark_as_read(
            message_id=notification.message_id,
            account_id=wrong_account_id,
        )

        # Should return None (not found for this account)
        self.assertIsNone(updated)

    def test_mark_all_as_read(self):
        """Test NotificationService.mark_all_as_read()."""
        # Create 5 PENDING notifications
        for i in range(5):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Notification {i}",
                body="Body",
            )

        # Mark all as read
        count = NotificationService.mark_all_as_read(
            account_id=self.account_id
        )

        # Should mark 5
        self.assertEqual(count, 5)

        # Verify all are DELIVERED
        unread_count = NotificationService.get_unread_count(
            account_id=self.account_id
        )
        self.assertEqual(unread_count, 0)


# ============================================================================
# API ENDPOINT TESTS (placeholders — require DRF views to be implemented)
# ============================================================================


class NotificationAPITestCase(APITestCase):
    """Test Notification API endpoints."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        """Create test account and JWT token."""
        self.account_id = str(uuid.uuid4())
        self.account = Accounts.objects.create(
            account_id=self.account_id,
            display_name="Test User",
            email="test@example.com",
            role="CUSTOMER",
            password_hash="hashed_password",
            active=True,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )

        # Token creation depends on project's auth setup; left as placeholder
        self.token = None

    def test_get_notifications_list_endpoint_returns_pagination(self):
        """Test GET /api/notifications/list returns paginated response."""
        # Create 5 notifications
        for i in range(5):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Notification {i}",
                body=f"Body {i}",
            )

        # TODO: call API endpoint once views are implemented
        pass

    def test_get_unread_count_endpoint(self):
        """Test GET /api/notifications/unread-count returns count."""
        # Create 3 PENDING notifications
        for i in range(3):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Notification {i}",
                body="Body",
            )

        # TODO: call API endpoint once views are implemented
        pass

    def test_mark_as_read_endpoint(self):
        """Test PATCH /api/notifications/{message_id}/read marks notification."""
        notification = NotificationService.create_notification(
            account_id=self.account_id,
            subject="Test",
            body="Body",
        )

        # TODO: call API endpoint once views are implemented
        pass

    def test_mark_all_as_read_endpoint(self):
        """Test PATCH /api/notifications/mark-all-read marks all as read."""
        # Create 5 PENDING notifications
        for i in range(5):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Notification {i}",
                body="Body",
            )

        # TODO: call API endpoint once views are implemented
        pass

    def test_unauthorized_request_returns_401(self):
        """Test endpoints return 401 without authentication."""
        # TODO: call API endpoint once views are implemented
        pass

    def test_pagination_query_parameters(self):
        """Test pagination with different page and limit parameters."""
        # Create 25 notifications
        for i in range(25):
            NotificationService.create_notification(
                account_id=self.account_id,
                subject=f"Notification {i}",
                body="Body",
            )

        # TODO: call API endpoint once views are implemented
        pass

    def test_notification_timestamp_format_in_response(self):
        """Test notification timestamps in API response are ISO 8601 UTC."""
        notification = NotificationService.create_notification(
            account_id=self.account_id,
            subject="Test",
            body="Body",
        )

        # TODO: call API endpoint once views are implemented
        pass
