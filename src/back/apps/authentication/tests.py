# apps/authentication/tests.py

import uuid

from django.test import TestCase
from django.db import connection
from django.utils import timezone
from django.core.cache import cache
from django.contrib.auth.hashers import make_password
from rest_framework.test import APIRequestFactory
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import AccessToken

from apps.authentication.models import Accounts
from apps.authentication.authentication import (
    CustomJWTAuthentication,
)
from apps.authentication.serializers import (
    RegisterSerializer,
    LoginSerializer,
)
from apps.authentication.views import get_tokens


class SQLiteAccountsTableMixin:
    """
    Manually creates accounts table because managed=False.
    """

    @classmethod
    def setUpClass(cls):
        super().setUpClass()

        with connection.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS accounts (
                    account_id TEXT PRIMARY KEY NOT NULL,
                    display_name TEXT NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    role TEXT NOT NULL,
                    password_hash TEXT NOT NULL,
                    phone_number TEXT,
                    active BOOLEAN NOT NULL,
                    created_at DATETIME NOT NULL,
                    updated_at DATETIME NOT NULL
                )
            """)

    @classmethod
    def tearDownClass(cls):
        with connection.cursor() as cursor:
            cursor.execute(
                "DROP TABLE IF EXISTS accounts"
            )

        super().tearDownClass()

    def tearDown(self):
        """
        Clean DB + cache after every test.
        """
        Accounts.objects.all().delete()
        cache.clear()

    def create_account(
        self,
        email="test@example.com",
        password="StrongPass123",
        active=True,
        role="customer",
    ):
        now = timezone.now()

        return Accounts.objects.create(
            account_id=str(uuid.uuid4()),
            display_name="Test User",
            email=email.lower(),
            role=role,
            password_hash=make_password(password),
            phone_number="01234567890",
            active=active,
            created_at=now,
            updated_at=now,
        )


# ==========================================================
# Token Tests
# ==========================================================

class TokenTests(
    SQLiteAccountsTableMixin,
    TestCase
):

    def test_get_tokens_contains_expected_fields(
        self
    ):
        account = self.create_account()

        tokens = get_tokens(account)
        access = AccessToken(
            tokens["access"]
        )

        self.assertEqual(
            access["account_id"],
            account.account_id
        )

        self.assertEqual(
            access["email"],
            account.email
        )

        self.assertEqual(
            access["role"],
            account.role
        )

        self.assertEqual(
            access["display_name"],
            account.display_name
        )


# ==========================================================
# Register Serializer Tests
# ==========================================================

class RegisterSerializerTests(
    SQLiteAccountsTableMixin,
    TestCase
):

    def test_register_serializer_valid(
        self
    ):
        serializer = RegisterSerializer(
            data={
                "display_name": "John",
                "email":
                    "john@example.com",
                "password":
                    "Password123",
            }
        )

        self.assertTrue(
            serializer.is_valid()
        )

    def test_register_serializer_duplicate_email(
        self
    ):
        self.create_account(
            email="john@example.com"
        )

        serializer = RegisterSerializer(
            data={
                "display_name": "John",
                "email":
                    "john@example.com",
                "password":
                    "Password123",
            }
        )

        self.assertFalse(
            serializer.is_valid()
        )

        self.assertIn(
            "email",
            serializer.errors
        )

    def test_register_serializer_invalid_email(
        self
    ):
        serializer = RegisterSerializer(
            data={
                "display_name": "John",
                "email":
                    "not-an-email",
                "password":
                    "Password123",
            }
        )

        self.assertFalse(
            serializer.is_valid()
        )


# ==========================================================
# Login Serializer Tests
# ==========================================================

class LoginSerializerTests(
    SQLiteAccountsTableMixin,
    TestCase
):

    def test_login_serializer_valid(
        self
    ):
        serializer = LoginSerializer(
            data={
                "email":
                    "john@example.com",
                "password":
                    "Password123"
            }
        )

        self.assertTrue(
            serializer.is_valid()
        )

    def test_login_serializer_invalid_email(
        self
    ):
        serializer = LoginSerializer(
            data={
                "email":
                    "bad-email",
                "password":
                    "Password123"
            }
        )

        self.assertFalse(
            serializer.is_valid()
        )


# ==========================================================
# Authentication Tests
# ==========================================================

class CustomJWTAuthenticationTests(
    SQLiteAccountsTableMixin,
    TestCase
):

    def setUp(self):
        self.factory = (
            APIRequestFactory()
        )
        self.auth = (
            CustomJWTAuthentication()
        )

    def test_authenticate_valid_token(
        self
    ):
        account = (
            self.create_account()
        )

        token = AccessToken()
        token["account_id"] = (
            account.account_id
        )

        request = (
            self.factory.get("/")
        )

        request.headers = {
            "Authorization":
            f"Bearer {token}"
        }

        user, validated_token = (
            self.auth.authenticate(
                request
            )
        )

        self.assertEqual(
            user.account_id,
            account.account_id
        )

    def test_authenticate_no_header(
        self
    ):
        request = (
            self.factory.get("/")
        )

        request.headers = {}

        result = (
            self.auth.authenticate(
                request
            )
        )

        self.assertIsNone(result)

    def test_authenticate_invalid_token(
        self
    ):
        request = (
            self.factory.get("/")
        )

        request.headers = {
            "Authorization":
            "Bearer invalidtoken"
        }

        with self.assertRaises(
            AuthenticationFailed
        ):
            self.auth.authenticate(
                request
            )

    def test_authenticate_nonexistent_account(
        self
    ):
        token = AccessToken()

        token["account_id"] = str(
            uuid.uuid4()
        )

        request = (
            self.factory.get("/")
        )

        request.headers = {
            "Authorization":
            f"Bearer {token}"
        }

        with self.assertRaises(
            AuthenticationFailed
        ):
            self.auth.authenticate(
                request
            )

    def test_authenticate_disabled_account(
        self
    ):
        account = (
            self.create_account(
                active=False
            )
        )

        token = AccessToken()

        token["account_id"] = (
            account.account_id
        )

        request = (
            self.factory.get("/")
        )

        request.headers = {
            "Authorization":
            f"Bearer {token}"
        }

        with self.assertRaises(
            AuthenticationFailed
        ):
            self.auth.authenticate(
                request
            )
