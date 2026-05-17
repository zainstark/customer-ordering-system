"""Tests for cart service and API behavior with JWT-only auth."""

import uuid

from django.db import connection
from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient, APITestCase
from rest_framework_simplejwt.tokens import AccessToken

from apps.authentication.models import Accounts
from apps.menu.models import MenuCatalog, MenuItem

from apps.cart.models import Cart, CartItem
from apps.cart.services import CartService


def _ensure_accounts_table():
    """Create accounts table for unmanaged auth model when absent in test DB."""
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


class CartServiceDummyDataTestCase(TestCase):
    """Ensure dummy menu fixtures still work through the provider seam."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        now = timezone.now()
        self.account = Accounts.objects.create(
            account_id='acct_dummy_001',
            display_name='Dummy Tester',
            email='dummy@test.local',
            role='customer',
            password_hash='hash',
            phone_number='',
            active=True,
            created_at=now,
            updated_at=now,
        )
        self.cart = Cart.objects.create(account=self.account)

        self.menu_fixture = {
            'menu_dummy_001': {
                'menu_item_id': 'menu_dummy_001',
                'name': 'Dummy Pizza',
                'description': 'Fixture description',
                'price_penny': 1234,
                'available': True,
                'image_url': 'https://example.test/dummy.png',
            }
        }
        CartService.set_menu_provider(lambda menu_item_id: self.menu_fixture.get(menu_item_id))

    def tearDown(self):
        CartService.set_menu_provider(None)

    def test_add_item_uses_dummy_fixture_price_snapshot(self):
        cart_item, error = CartService.add_item_to_cart(
            self.cart.cart_id,
            'menu_dummy_001',
            2,
        )

        self.assertIsNone(error)
        self.assertIsNotNone(cart_item)
        self.assertEqual(cart_item.menu_item_id, 'menu_dummy_001')
        self.assertEqual(cart_item.unit_price_snapshot, 1234)
        self.assertEqual(cart_item.line_total, 2468)

    def test_validate_cart_detects_dummy_price_change(self):
        CartItem.objects.create(
            cart=self.cart,
            menu_item_id='menu_dummy_001',
            quantity=1,
            unit_price_snapshot=1000,
        )

        is_valid, issues = CartService.validate_cart_items(self.cart.cart_id)

        self.assertFalse(is_valid)
        self.assertEqual(len(issues), 1)
        self.assertIn('Price has changed', issues[0]['issue'])


class CartAPIJWTTestCase(APITestCase):
    """API tests requiring generated bearer tokens and ownership checks."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.client = APIClient()
        now = timezone.now()

        self.account_a = Accounts.objects.create(
            account_id='acct_api_001',
            display_name='API User A',
            email='apia@test.local',
            role='customer',
            password_hash='hash',
            phone_number='',
            active=True,
            created_at=now,
            updated_at=now,
        )
        self.account_b = Accounts.objects.create(
            account_id='acct_api_002',
            display_name='API User B',
            email='apib@test.local',
            role='customer',
            password_hash='hash',
            phone_number='',
            active=True,
            created_at=now,
            updated_at=now,
        )

        self.catalog = MenuCatalog.objects.create(
            catalog_id=f'cat_{uuid.uuid4()}',
            name='Main Menu',
            active=True,
        )
        self.menu_item = MenuItem.objects.create(
            menu_item_id='menu_api_001',
            catalog=self.catalog,
            name='API Burger',
            description='Beef burger',
            price_penny=1599,
            category='Burger',
            available=True,
            image_url='https://example.test/burger.png',
        )

    def _access_token_for(self, account):
        access = AccessToken()
        access['account_id'] = account.account_id
        access['email'] = account.email
        access['role'] = account.role
        access['display_name'] = account.display_name
        return str(access)

    def _authenticate(self, account):
        token = self._access_token_for(account)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    def test_get_cart_requires_generated_token(self):
        response = self.client.get('/api/cart/')
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    def test_get_cart_uses_token_account_not_query_account(self):
        self._authenticate(self.account_a)
        response = self.client.get('/api/cart/', {'account_id': self.account_b.account_id})

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['accountId'], self.account_a.account_id)

    def test_add_item_returns_flutter_item_shape(self):
        self._authenticate(self.account_a)
        response = self.client.post(
            '/api/cart/items/',
            {
                'account_id': self.account_b.account_id,
                'menu_item_id': self.menu_item.menu_item_id,
                'quantity': 2,
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('items', response.data)
        self.assertEqual(len(response.data['items']), 1)

        item = response.data['items'][0]
        self.assertEqual(
            sorted(item.keys()),
            sorted(['id', 'cartId', 'menuItemId', 'title', 'subtitle', 'unitPrice', 'quantity', 'imageUrl']),
        )
        self.assertEqual(item['menuItemId'], self.menu_item.menu_item_id)
        self.assertEqual(item['title'], self.menu_item.name)
        self.assertEqual(item['unitPrice'], 15.99)

    def test_update_item_in_other_account_cart_returns_404(self):
        cart_b = Cart.objects.create(account=self.account_b)
        item_b = CartItem.objects.create(
            cart=cart_b,
            menu_item=self.menu_item,
            quantity=1,
            unit_price_snapshot=1599,
        )

        self._authenticate(self.account_a)
        response = self.client.patch(
            f'/api/cart/items/{item_b.cart_item_id}/',
            {'quantity': 3},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_delete_item_in_other_account_cart_returns_404(self):
        cart_b = Cart.objects.create(account=self.account_b)
        item_b = CartItem.objects.create(
            cart=cart_b,
            menu_item=self.menu_item,
            quantity=1,
            unit_price_snapshot=1599,
        )

        self._authenticate(self.account_a)
        response = self.client.delete(f'/api/cart/items/{item_b.cart_item_id}/delete/')

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
