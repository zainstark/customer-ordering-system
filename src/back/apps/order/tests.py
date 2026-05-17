import uuid
from datetime import timedelta

from django.db import connection
from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient, APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

from apps.authentication.models import Accounts
from apps.cart.models import Cart, CartItem
from apps.cart.services import CartService
from apps.menu.models import Category, MenuCatalog, MenuItem

from apps.order.models import Orders as Order, OrderItems
from apps.order.services import OrderService



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


def _make_account(suffix: str, active: bool = True) -> Accounts:
    """Create and persist a minimal Accounts row."""
    now = timezone.now()
    return Accounts.objects.create(
        account_id=f"acct_{suffix}",
        display_name=f"User {suffix}",
        email=f"{suffix}@test.local",
        role="customer",
        password_hash="hash",
        phone_number="",
        active=active,
        created_at=now,
        updated_at=now,
    )


def _make_catalog(suffix: str = "") -> MenuCatalog:
    return MenuCatalog.objects.create(
        catalog_id=f"cat_{uuid.uuid4()}",
        name=f"Test Catalog {suffix}",
        active=True,
    )


def _make_menu_item(catalog: MenuCatalog, *, price_penny: int = 1000,
                    available: bool = True, suffix: str = "") -> MenuItem:
    category, _ = Category.objects.get_or_create(category_id="test_category", defaults={"name": "Test Category"})
    return MenuItem.objects.create(
        menu_item_id=f"item_{uuid.uuid4()}",
        catalog=catalog,
        name=f"Test Item {suffix}",
        description=f"Description {suffix}",
        price_penny=price_penny,
        category_fk=category,
        available=available,
        image_url="https://example.test/item.png",
    )


def _fill_cart(cart: Cart, menu_item: MenuItem, quantity: int = 1) -> CartItem:
    """Add a CartItem to a cart, using the menu item's current price."""
    return CartItem.objects.create(
        cart=cart,
        menu_item=menu_item,
        quantity=quantity,
        unit_price_snapshot=menu_item.price_penny,
    )


class OrderServicePlaceOrderTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.catalog = _make_catalog()
        self.account = _make_account("svc_001")
        self.cart = Cart.objects.create(account=self.account)
        self.menu_item = _make_menu_item(self.catalog, price_penny=1500, suffix="A")

    def test_place_order_returns_order_object(self):
        _fill_cart(self.cart, self.menu_item, quantity=2)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        self.assertIsNotNone(order)
        self.assertIsInstance(order, Order)

    def test_place_order_sets_status_pending(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        self.assertEqual(order.order_status, "PENDING")

    def test_place_order_total_is_computed_in_pennies(self):
        _fill_cart(self.cart, self.menu_item, quantity=2)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        self.assertEqual(order.total_amount, 3000)

    def test_place_order_total_uses_live_price_not_snapshot(self):
        cart_item = _fill_cart(self.cart, self.menu_item, quantity=1)
        cart_item.unit_price_snapshot = 1 
        cart_item.save()

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        self.assertEqual(order.total_amount, 1500)

    def test_place_order_creates_order_items_with_snapshots(self):
        _fill_cart(self.cart, self.menu_item, quantity=3)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        order_items = OrderItems.objects.filter(order=order)
        self.assertEqual(order_items.count(), 1)

        oi = order_items.first()
        self.assertEqual(oi.item_name_snapshot, self.menu_item.name)
        self.assertEqual(oi.unit_price_snapshot, self.menu_item.price_penny)
        self.assertEqual(oi.quantity, 3)
        self.assertEqual(oi.line_total, 3 * self.menu_item.price_penny)

    def test_place_order_with_multiple_items(self):
        item_b = _make_menu_item(self.catalog, price_penny=500, suffix="B")
        _fill_cart(self.cart, self.menu_item, quantity=1)   # 1500
        _fill_cart(self.cart, item_b, quantity=2)           # 1000

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        self.assertEqual(order.total_amount, 2500)
        self.assertEqual(OrderItems.objects.filter(order=order).count(), 2)

    def test_place_order_clears_cart_after_success(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(error)
        self.assertEqual(CartItem.objects.filter(cart=self.cart).count(), 0)

    def test_place_order_stores_address(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)
        address = "456 Example Avenue, Cairo"

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address=address,
        )

        self.assertIsNone(error)
        self.assertEqual(order.address, address)

    def test_place_order_persists_to_database(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)

        order, _ = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertTrue(Order.objects.filter(order_id=order.order_id).exists())

    def test_place_order_empty_cart_returns_error(self):
        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(order)
        self.assertIsNotNone(error)
        self.assertIn("empty", error.lower())

    def test_place_order_empty_cart_creates_no_order_row(self):
        OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertEqual(
            Order.objects.filter(account_id=self.account.account_id).count(), 0
        )


    def test_place_order_no_cart_returns_error(self):
        account_no_cart = _make_account("svc_no_cart")

        order, error = OrderService.place_order(
            account_id=account_no_cart.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(order)
        self.assertIsNotNone(error)

    def test_place_order_unavailable_item_returns_error(self):
        unavailable_item = _make_menu_item(
            self.catalog, price_penny=1000, available=False, suffix="Unavail"
        )
        _fill_cart(self.cart, unavailable_item, quantity=1)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(order)
        self.assertIsNotNone(error)
        self.assertIn(unavailable_item.name, error)

    def test_place_order_unavailable_item_creates_no_order_row(self):
        unavailable_item = _make_menu_item(
            self.catalog, available=False, suffix="Unavail2"
        )
        _fill_cart(self.cart, unavailable_item, quantity=1)

        OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertEqual(
            Order.objects.filter(account_id=self.account.account_id).count(), 0
        )

    def test_place_order_unavailable_item_does_not_clear_cart(self):
        """
        When placement fails, the cart must be preserved so the customer
        can correct it and retry.
        """
        unavailable_item = _make_menu_item(
            self.catalog, available=False, suffix="Unavail3"
        )
        _fill_cart(self.cart, unavailable_item, quantity=2)

        OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertEqual(CartItem.objects.filter(cart=self.cart).count(), 1)

    def test_place_order_mixed_available_and_unavailable_items_fails(self):
        available_item = _make_menu_item(self.catalog, available=True, suffix="Avail")
        unavailable_item = _make_menu_item(self.catalog, available=False, suffix="Unavail4")
        _fill_cart(self.cart, available_item, quantity=1)
        _fill_cart(self.cart, unavailable_item, quantity=1)

        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertIsNone(order)
        self.assertIsNotNone(error)

    def test_place_order_idempotency_within_30_seconds(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)

        order1, error1 = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )
        self.assertIsNone(error1)

        _fill_cart(self.cart, self.menu_item, quantity=1)

        order2, error2 = OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )
        self.assertIsNone(error2)
        self.assertEqual(order1.order_id, order2.order_id)
        self.assertEqual(Order.objects.filter(account_id=self.account.account_id).count(), 1)

    def test_place_order_is_atomic_on_failure(self):
        available_item = _make_menu_item(self.catalog, available=True, suffix="AtomA")
        unavailable_item = _make_menu_item(self.catalog, available=False, suffix="AtomB")
        _fill_cart(self.cart, available_item, quantity=1)
        _fill_cart(self.cart, unavailable_item, quantity=1)

        OrderService.place_order(
            account_id=self.account.account_id,
            address="123 Test Street",
        )

        self.assertEqual(Order.objects.count(), 0)
        self.assertEqual(OrderItems.objects.count(), 0)


class OrderServiceGetOrdersTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.account_a = _make_account("get_a")
        self.account_b = _make_account("get_b")
        self.catalog = _make_catalog()
        self.menu_item = _make_menu_item(self.catalog, price_penny=1000)
        self.cart_a = Cart.objects.create(account=self.account_a)
        self.cart_b = Cart.objects.create(account=self.account_b)

    def _place(self, account_id: str):
        cart = Cart.objects.get(account_id=account_id)
        _fill_cart(cart, self.menu_item, quantity=1)
        order, _ = OrderService.place_order(
            account_id=account_id,
            address="Test Address",
        )
        return order

    def test_returns_only_own_orders(self):
        self._place(self.account_a.account_id)
        self._place(self.account_b.account_id)

        orders = OrderService.get_orders_for_account(self.account_a.account_id)

        self.assertEqual(len(orders), 1)
        self.assertEqual(orders[0].account_id, self.account_a.account_id)

    def test_returns_empty_list_when_no_orders(self):
        orders = OrderService.get_orders_for_account(self.account_a.account_id)
        self.assertEqual(list(orders), [])

    def test_returns_multiple_orders_newest_first(self):
        order1 = self._place(self.account_a.account_id)
        # Move the first order out of the idempotency window
        order1.order_status = "DELIVERED"
        order1.save()
        # Re-fill cart for second order
        _fill_cart(self.cart_a, self.menu_item, quantity=2)
        order2, _ = OrderService.place_order(
            account_id=self.account_a.account_id,
            address="Test Address",
        )

        orders = OrderService.get_orders_for_account(self.account_a.account_id)

        self.assertEqual(len(orders), 2)
        self.assertGreaterEqual(orders[0].placed_at, orders[1].placed_at)


class OrderAPITestCase(APITestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.client = APIClient()
        self.catalog = _make_catalog()
        self.menu_item = _make_menu_item(self.catalog, price_penny=1000, suffix="API")

        self.account_a = _make_account("api_a")
        self.account_b = _make_account("api_b")

        self.cart_a = Cart.objects.create(account=self.account_a)
        self.cart_b = Cart.objects.create(account=self.account_b)

    def _access_token_for(self, account: Accounts) -> str:
        refresh = RefreshToken()
        refresh["account_id"] = account.account_id
        refresh["email"] = account.email
        refresh["role"] = account.role
        refresh["display_name"] = account.display_name
        return str(refresh.access_token)

    def _authenticate(self, account: Accounts):
        token = self._access_token_for(account)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def _place_order_request(self, address: str = "123 Test Street"):
        return self.client.post(
            "/api/order/place/",
            {"address": address},
            format="json",
        )

    # -- Authentication guard ------------------------------------------------

    def test_place_order_requires_auth(self):
        response = self._place_order_request()
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    def test_list_orders_requires_auth(self):
        response = self.client.get("/api/order/")
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    def test_place_order_invalid_token_returns_401(self):
        self.client.credentials(HTTP_AUTHORIZATION="Bearer this.is.not.valid")
        response = self._place_order_request()
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    def test_place_order_inactive_account_is_rejected(self):
        inactive = _make_account("inactive_01", active=False)
        self.client.credentials(
            HTTP_AUTHORIZATION=f"Bearer {self._access_token_for(inactive)}"
        )
        response = self._place_order_request()
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    # -- place_order happy path ----------------------------------------------

    def test_place_order_success_returns_201(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_place_order_response_has_required_fields(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        for field in ["orderId", "accountId", "status", "placedAt", "totalAmount", "progress"]:
            self.assertIn(field, response.data, msg=f"Missing field: {field}")

    def test_place_order_response_total_amount_is_float_in_dollars(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=2)  # 2 × $10.00

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertAlmostEqual(float(response.data["totalAmount"]), 20.00, places=2)

    def test_place_order_response_status_is_pending(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["status"], "PENDING")

    def test_place_order_response_progress_is_float(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        progress = float(response.data["progress"])
        self.assertGreaterEqual(progress, 0.0)
        self.assertLessEqual(progress, 1.0)

    def test_place_order_response_account_id_matches_token(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["accountId"], self.account_a.account_id)

    def test_place_order_response_contains_items(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=2)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn("items", response.data)
        self.assertEqual(len(response.data["items"]), 1)

    def test_place_order_uses_account_from_token_not_body(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self.client.post(
            "/api/order/place/",
            {"address": "Test Street", "account_id": self.account_b.account_id},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["accountId"], self.account_a.account_id)
        # account_b must have no orders
        self.assertEqual(
            Order.objects.filter(account_id=self.account_b.account_id).count(), 0
        )

    def test_place_order_clears_cart(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(CartItem.objects.filter(cart=self.cart_a).count(), 0)


    def test_place_order_empty_cart_returns_400(self):
        self._authenticate(self.account_a)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("error", response.data)

    def test_place_order_empty_cart_body_contains_helpful_message(self):
        self._authenticate(self.account_a)

        response = self._place_order_request()

        self.assertIn("empty", response.data["error"].lower())


    def test_place_order_unavailable_item_returns_400(self):
        self._authenticate(self.account_a)
        unavailable = _make_menu_item(
            self.catalog, available=False, suffix="UnavailAPI"
        )
        _fill_cart(self.cart_a, unavailable, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("error", response.data)

    def test_place_order_unavailable_item_names_the_item(self):
        self._authenticate(self.account_a)
        unavailable = _make_menu_item(
            self.catalog, available=False, suffix="NamedItem"
        )
        _fill_cart(self.cart_a, unavailable, quantity=1)

        response = self._place_order_request()

        self.assertIn(unavailable.name, response.data["error"])

    def test_place_order_unavailable_item_does_not_clear_cart(self):
        self._authenticate(self.account_a)
        unavailable = _make_menu_item(
            self.catalog, available=False, suffix="CartPreserve"
        )
        _fill_cart(self.cart_a, unavailable, quantity=1)

        self._place_order_request()

        self.assertEqual(CartItem.objects.filter(cart=self.cart_a).count(), 1)

    def test_place_order_missing_address_returns_400(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self.client.post("/api/order/place/", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_place_order_total_comes_from_db_not_client(self):
        
        self._authenticate(self.account_a)
        cart_item = _fill_cart(self.cart_a, self.menu_item, quantity=1)
        cart_item.unit_price_snapshot = 1
        cart_item.save()

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertAlmostEqual(float(response.data["totalAmount"]), 10.00, places=2)


    def test_place_order_duplicate_within_30s_returns_same_order(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response1 = self._place_order_request()
        self.assertEqual(response1.status_code, status.HTTP_201_CREATED)

        _fill_cart(self.cart_a, self.menu_item, quantity=1)
        response2 = self._place_order_request()
        self.assertEqual(response2.status_code, status.HTTP_201_CREATED)

        self.assertEqual(response1.data["orderId"], response2.data["orderId"])
        self.assertEqual(
            Order.objects.filter(account_id=self.account_a.account_id).count(), 1
        )


    def test_list_orders_returns_200(self):
        self._authenticate(self.account_a)

        response = self.client.get("/api/order/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_list_orders_returns_empty_list_when_no_orders(self):
        self._authenticate(self.account_a)

        response = self.client.get("/api/order/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, [])

    def test_list_orders_returns_own_orders_only(self):
        _fill_cart(self.cart_a, self.menu_item, quantity=1)
        OrderService.place_order(
            account_id=self.account_a.account_id,
            address="Address A",
        )

        _fill_cart(self.cart_b, self.menu_item, quantity=1)
        OrderService.place_order(
            account_id=self.account_b.account_id,
            address="Address B",
        )

        self._authenticate(self.account_a)
        response = self.client.get("/api/order/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["accountId"], self.account_a.account_id)

    def test_list_orders_response_items_have_required_fields(self):
        _fill_cart(self.cart_a, self.menu_item, quantity=1)
        OrderService.place_order(
            account_id=self.account_a.account_id,
            address="Test Address",
        )

        self._authenticate(self.account_a)
        response = self.client.get("/api/order/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

        order_data = response.data[0]
        for field in ["orderId", "accountId", "status", "placedAt", "totalAmount", "progress"]:
            self.assertIn(field, order_data, msg=f"Missing field: {field}")

    def test_list_orders_newest_first(self):
        _fill_cart(self.cart_a, self.menu_item, quantity=1)
        order1, _ = OrderService.place_order(
            account_id=self.account_a.account_id,
            address="First Order",
        )
        # Move the first order out of the idempotency window
        order1.order_status = "DELIVERED"
        order1.save()
        _fill_cart(self.cart_a, self.menu_item, quantity=2)
        OrderService.place_order(
            account_id=self.account_a.account_id,
            address="Second Order",
        )

        self._authenticate(self.account_a)
        response = self.client.get("/api/order/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        t0 = response.data[0]["placedAt"]
        t1 = response.data[1]["placedAt"]
        self.assertGreaterEqual(t0, t1)

    def test_list_orders_account_id_comes_from_token(self):
        """
        Supplying a different account_id as a query param must not leak
        that account's orders; the token account is always used.
        """
        _fill_cart(self.cart_b, self.menu_item, quantity=1)
        OrderService.place_order(
            account_id=self.account_b.account_id,
            address="B's Address",
        )

        self._authenticate(self.account_a)
        response = self.client.get(
            "/api/order/",
            {"account_id": self.account_b.account_id},
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # account_a has no orders, so the list must be empty
        self.assertEqual(len(response.data), 0)

    # -- Serializer shape details --------------------------------------------

    def test_order_item_shape_inside_order_response(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=3)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        items = response.data.get("items", [])
        self.assertEqual(len(items), 1)

        item = items[0]
        for field in ["id", "title", "unitPrice", "quantity", "lineTotal"]:
            self.assertIn(field, item, msg=f"Missing item field: {field}")

        self.assertAlmostEqual(float(item["unitPrice"]), 10.00, places=2)
        self.assertEqual(item["quantity"], 3)
        self.assertAlmostEqual(float(item["lineTotal"]), 30.00, places=2)

    def test_progress_value_for_pending_status(self):
        self._authenticate(self.account_a)
        _fill_cart(self.cart_a, self.menu_item, quantity=1)

        response = self._place_order_request()

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertAlmostEqual(float(response.data["progress"]), 0.1, places=2)