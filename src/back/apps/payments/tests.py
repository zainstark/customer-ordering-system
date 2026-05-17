import uuid
from datetime import timedelta
from unittest.mock import Mock, patch

from django.db import connection
from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient, APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

from apps.authentication.models import Accounts
from apps.cart.models import Cart, CartItem
from apps.menu.models import Category, MenuCatalog, MenuItem
from apps.order.models import OrderItems, Orders as Order
from apps.order.services import OrderService
from apps.payments.adapters import PaymentGatewayAdapter
from apps.payments.models import Payment
from apps.payments.services import PaymentService


def _ensure_accounts_table():
    table_name = Accounts._meta.db_table
    existing_tables = connection.introspection.table_names()
    if table_name in existing_tables:
        return

    with connection.cursor() as cursor:
        cursor.execute(
            '''
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
            '''
        )


def _make_account(suffix: str, active: bool = True) -> Accounts:
    now = timezone.now()
    return Accounts.objects.create(
        account_id=f'acct_pay_{suffix}',
        display_name=f'Payment User {suffix}',
        email=f'{suffix}@payments.test',
        role='customer',
        password_hash='hash',
        phone_number='',
        active=active,
        created_at=now,
        updated_at=now,
    )


def _make_catalog(suffix: str = '') -> MenuCatalog:
    return MenuCatalog.objects.create(
        catalog_id=f'cat_{uuid.uuid4()}',
        name=f'Payment Catalog {suffix}',
        active=True,
    )


def _make_menu_item(catalog: MenuCatalog, *, price_penny: int = 1000, available: bool = True, suffix: str = '') -> MenuItem:
    category, _ = Category.objects.get_or_create(
        category_id='payment_category',
        defaults={'name': 'Payment Category'},
    )
    return MenuItem.objects.create(
        menu_item_id=f'item_{uuid.uuid4()}',
        catalog=catalog,
        name=f'Payment Item {suffix}',
        description='Payment test item',
        price_penny=price_penny,
        category_fk=category,
        available=available,
        image_url='https://example.test/payment.png',
    )


def _fill_cart(cart: Cart, menu_item: MenuItem, quantity: int = 1) -> CartItem:
    return CartItem.objects.create(
        cart=cart,
        menu_item=menu_item,
        quantity=quantity,
        unit_price_snapshot=menu_item.price_penny,
    )


class PaymentServiceOrderValidationTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.catalog = _make_catalog('validation')
        self.account = _make_account('validation_a')
        self.other_account = _make_account('validation_b')
        self.cart = Cart.objects.create(account=self.account)
        self.menu_item = _make_menu_item(self.catalog, price_penny=1200, available=True, suffix='A')
        self.order = self._create_order(self.account, self.menu_item)

    def _create_order(self, account: Accounts, menu_item: MenuItem, status: str = 'PENDING') -> Order:
        order = Order.objects.create(
            account=account,
            total_amount=menu_item.price_penny,
            address='123 Payment Lane',
            order_status=status,
            placed_at=timezone.now(),
        )
        OrderItems.objects.create(
            order=order,
            menu_item=menu_item,
            item_name_snapshot=menu_item.name,
            item_description_snapshot=menu_item.description,
            unit_price_snapshot=menu_item.price_penny,
            quantity=1,
        )
        return order

    def test_create_payment_session_rejects_non_owned_order(self):
        external_order = self._create_order(self.other_account, self.menu_item)

        payment, error = PaymentService.create_payment_session(
            account_id=self.account.account_id,
            order_id=external_order.order_id,
            payment_method='CARD',
        )

        self.assertIsNone(payment)
        self.assertIsNotNone(error)
        self.assertIn('not found', error.lower())

    def test_create_payment_session_rejects_already_paid_order(self):
        paid_order = self._create_order(self.account, self.menu_item, status='PAID')

        payment, error = PaymentService.create_payment_session(
            account_id=self.account.account_id,
            order_id=paid_order.order_id,
            payment_method='CARD',
        )

        self.assertIsNone(payment)
        self.assertIsNotNone(error)
        self.assertIn('already paid', error.lower())

    def test_create_payment_session_returns_session_for_valid_order(self):
        adapter = Mock(spec=PaymentGatewayAdapter)
        adapter.create_payment_intent.return_value = {
            'id': 'pi_test_123',
            'client_secret': 'secret_test',
            'status': 'requires_payment_method',
            'url': 'https://checkout.test/session/123',
        }

        PaymentService.set_gateway_adapter(adapter)

        payment, error = PaymentService.create_payment_session(
            account_id=self.account.account_id,
            order_id=self.order.order_id,
            payment_method='CARD',
        )

        self.assertIsNone(error)
        self.assertIsNotNone(payment)
        self.assertEqual(payment.checkout_url, 'https://checkout.test/session/123')
        self.assertEqual(payment.payment_status, 'INITIATED')

    def test_create_payment_session_is_idempotent(self):
        adapter = Mock(spec=PaymentGatewayAdapter)
        adapter.create_payment_intent.return_value = {
            'id': 'pi_test_456',
            'client_secret': 'secret_test',
            'status': 'requires_payment_method',
            'url': 'https://checkout.test/session/456',
        }
        PaymentService.set_gateway_adapter(adapter)

        first_payment, first_error = PaymentService.create_payment_session(
            account_id=self.account.account_id,
            order_id=self.order.order_id,
            payment_method='CARD',
        )
        second_payment, second_error = PaymentService.create_payment_session(
            account_id=self.account.account_id,
            order_id=self.order.order_id,
            payment_method='CARD',
        )

        self.assertIsNone(first_error)
        self.assertIsNone(second_error)
        self.assertEqual(first_payment.payment_id, second_payment.payment_id)
        self.assertEqual(Payment.objects.filter(order=self.order).count(), 1)

    def test_validate_order_for_payment_rejects_empty_order(self):
        empty_order = Order.objects.create(
            account=self.account,
            total_amount=0,
            address='Empty Lane',
            order_status='PENDING',
            placed_at=timezone.now(),
        )

        payment, error = PaymentService.create_payment_session(
            account_id=self.account.account_id,
            order_id=empty_order.order_id,
            payment_method='CARD',
        )

        self.assertIsNone(payment)
        self.assertIsNotNone(error)
        self.assertIn('empty', error.lower())


class PaymentGatewayAdapterTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()

    def test_adapter_create_payment_intent_throws_timeout(self):
        adapter = Mock(spec=PaymentGatewayAdapter)
        adapter.create_payment_intent.side_effect = TimeoutError('Gateway timed out')

        with self.assertRaises(TimeoutError):
            adapter.create_payment_intent(
                amount_pennies=1000,
                currency='usd',
                payment_method='CARD',
                order_id='order_test',
            )

    def test_adapter_create_payment_intent_raises_for_malformed_response(self):
        adapter = Mock(spec=PaymentGatewayAdapter)
        adapter.create_payment_intent.return_value = {'unexpected': 'payload'}

        response = adapter.create_payment_intent(
            amount_pennies=1000,
            currency='usd',
            payment_method='CARD',
            order_id='order_test',
        )

        self.assertIn('unexpected', response)


class PaymentServiceStateTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.catalog = _make_catalog('state')
        self.account = _make_account('state_a')
        self.menu_item = _make_menu_item(self.catalog, price_penny=2000, suffix='State')
        self.order = Order.objects.create(
            account=self.account,
            total_amount=2000,
            address='State Blvd',
            order_status='PENDING',
            placed_at=timezone.now(),
        )
        OrderItems.objects.create(
            order=self.order,
            menu_item=self.menu_item,
            item_name_snapshot=self.menu_item.name,
            item_description_snapshot=self.menu_item.description,
            unit_price_snapshot=self.menu_item.price_penny,
            quantity=1,
        )
        self.payment = Payment.objects.create(
            order=self.order,
            payment_method='CARD',
            payment_status='INITIATED',
            amount=self.order.total_amount,
            attempt_count=0,
        )

    def test_payment_initial_state_is_initiated(self):
        self.assertEqual(self.payment.payment_status, 'INITIATED')

    def test_retry_payment_increments_attempt_count(self):
        with patch.object(PaymentService, 'retry_payment', return_value=({'retryCount': 1}, None)) as retry_method:
            result, error = PaymentService.retry_payment(self.account.account_id, self.payment.payment_id)
            self.assertIsNone(error)
            self.assertEqual(result['retryCount'], 1)
            retry_method.assert_called_once()


class PaymentWebhookTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def test_process_webhook_invalid_signature_is_rejected(self):
        result, error = PaymentService.process_webhook(b'{}', 'invalid-signature')
        self.assertIsNone(result)
        self.assertIsNotNone(error)

    def test_process_webhook_valid_signature_finalizes_payment(self):
        adapter = Mock(spec=PaymentGatewayAdapter)
        adapter.verify_webhook_signature.return_value = True
        PaymentService.set_gateway_adapter(adapter)

        result, error = PaymentService.process_webhook(b'{}', 'valid-signature')
        self.assertIsNone(error)
        self.assertIsNotNone(result)


class PaymentAPITestCase(APITestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.client = APIClient()
        self.account = _make_account('api_a')
        self.catalog = _make_catalog('api')
        self.menu_item = _make_menu_item(self.catalog, price_penny=1000, suffix='API')
        self.cart = Cart.objects.create(account=self.account)
        _fill_cart(self.cart, self.menu_item, quantity=1)

    def _access_token_for(self, account: Accounts) -> str:
        refresh = RefreshToken()
        refresh['account_id'] = account.account_id
        refresh['email'] = account.email
        refresh['role'] = account.role
        refresh['display_name'] = account.display_name
        return str(refresh.access_token)

    def _authenticate(self):
        token = self._access_token_for(self.account)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    def test_create_payment_session_requires_auth(self):
        response = self.client.post('/api/payments/create-session/', {'orderId': 'none', 'paymentMethod': 'CARD'}, format='json')
        self.assertIn(response.status_code, [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_get_payment_status_requires_auth(self):
        response = self.client.get('/api/payments/some-id/status/')
        self.assertIn(response.status_code, [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_retry_payment_requires_auth(self):
        response = self.client.post('/api/payments/some-id/retry/')
        self.assertIn(response.status_code, [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_webhook_requires_signature_header(self):
        response = self.client.post('/api/payments/webhook/', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('error', response.data)
