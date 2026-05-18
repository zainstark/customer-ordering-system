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

from apps.order.models import Orders as Order, OrderItems, OrderStatusHistory
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
    category, _ = Category.objects.get_or_create(
        category_id="test_category",
        defaults={"name": "Test Category"},
    )
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
    return CartItem.objects.create(
        cart=cart,
        menu_item=menu_item,
        quantity=quantity,
        unit_price_snapshot=menu_item.price_penny,
    )


def _seed_history(order: Order, status_value: str,
                  minutes_ago: int = 0) -> OrderStatusHistory:
    return OrderStatusHistory.objects.create(
        order=order,
        order_status=status_value,
        changed_at=timezone.now() - timedelta(minutes=minutes_ago),
    )


_EXPECTED_PROGRESS = {
    "PENDING":          0,
    "CONFIRMED":        20,
    "PREPARING":        50,
    "READY":            70,
    "OUT_FOR_DELIVERY": 90,
    "DELIVERED":        100,
}

_EXPECTED_STATUS_LABEL = {
    "PENDING":          "pending",
    "CONFIRMED":        "confirmed",
    "PREPARING":        "preparing",
    "READY":            "ready",
    "OUT_FOR_DELIVERY": "delivery",
    "DELIVERED":        "delivered",
}

_TERMINAL_STATUSES = {"DELIVERED", "CANCELLED", "FAILED", "REFUNDED"}


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
        _fill_cart(self.cart, self.menu_item, quantity=1)
        _fill_cart(self.cart, item_b, quantity=2)
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
        order1.order_status = "DELIVERED"
        order1.save()
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

    def test_place_order_requires_auth(self):
        response = self._place_order_request()
        self.assertIn(response.status_code,
                      [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_list_orders_requires_auth(self):
        response = self.client.get("/api/order/")
        self.assertIn(response.status_code,
                      [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_place_order_invalid_token_returns_401(self):
        self.client.credentials(HTTP_AUTHORIZATION="Bearer this.is.not.valid")
        response = self._place_order_request()
        self.assertIn(response.status_code,
                      [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_place_order_inactive_account_is_rejected(self):
        inactive = _make_account("inactive_01", active=False)
        self.client.credentials(
            HTTP_AUTHORIZATION=f"Bearer {self._access_token_for(inactive)}"
        )
        response = self._place_order_request()
        self.assertIn(response.status_code,
                      [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

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
        _fill_cart(self.cart_a, self.menu_item, quantity=2)
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
        unavailable = _make_menu_item(self.catalog, available=False, suffix="UnavailAPI")
        _fill_cart(self.cart_a, unavailable, quantity=1)
        response = self._place_order_request()
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("error", response.data)

    def test_place_order_unavailable_item_names_the_item(self):
        self._authenticate(self.account_a)
        unavailable = _make_menu_item(self.catalog, available=False, suffix="NamedItem")
        _fill_cart(self.cart_a, unavailable, quantity=1)
        response = self._place_order_request()
        self.assertIn(unavailable.name, response.data["error"])

    def test_place_order_unavailable_item_does_not_clear_cart(self):
        self._authenticate(self.account_a)
        unavailable = _make_menu_item(self.catalog, available=False, suffix="CartPreserve")
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
        OrderService.place_order(account_id=self.account_a.account_id, address="Address A")
        _fill_cart(self.cart_b, self.menu_item, quantity=1)
        OrderService.place_order(account_id=self.account_b.account_id, address="Address B")
        self._authenticate(self.account_a)
        response = self.client.get("/api/order/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["accountId"], self.account_a.account_id)

    def test_list_orders_response_items_have_required_fields(self):
        _fill_cart(self.cart_a, self.menu_item, quantity=1)
        OrderService.place_order(account_id=self.account_a.account_id, address="Test Address")
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
            account_id=self.account_a.account_id, address="First Order"
        )
        order1.order_status = "DELIVERED"
        order1.save()
        _fill_cart(self.cart_a, self.menu_item, quantity=2)
        OrderService.place_order(account_id=self.account_a.account_id, address="Second Order")
        self._authenticate(self.account_a)
        response = self.client.get("/api/order/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        t0 = response.data[0]["placedAt"]
        t1 = response.data[1]["placedAt"]
        self.assertGreaterEqual(t0, t1)

    def test_list_orders_account_id_comes_from_token(self):
        _fill_cart(self.cart_b, self.menu_item, quantity=1)
        OrderService.place_order(account_id=self.account_b.account_id, address="B's Address")
        self._authenticate(self.account_a)
        response = self.client.get("/api/order/", {"account_id": self.account_b.account_id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

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


class OrderStatusHistorySeedingTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.catalog = _make_catalog()
        self.account = _make_account("hist_seed_001")
        self.cart = Cart.objects.create(account=self.account)
        self.menu_item = _make_menu_item(self.catalog, price_penny=1000, suffix="Hist")

    def test_place_order_creates_initial_history_entry(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)
        order, error = OrderService.place_order(
            account_id=self.account.account_id,
            address="1 History Lane",
        )
        self.assertIsNone(error)
        history_qs = OrderStatusHistory.objects.filter(order=order)
        self.assertGreaterEqual(
            history_qs.count(), 1,
            "place_order must seed at least one OrderStatusHistory row.",
        )

    def test_initial_history_entry_has_pending_status(self):
        _fill_cart(self.cart, self.menu_item, quantity=1)
        order, _ = OrderService.place_order(
            account_id=self.account.account_id,
            address="1 History Lane",
        )
        first_entry = (
            OrderStatusHistory.objects
            .filter(order=order)
            .order_by("changed_at")
            .first()
        )
        self.assertIsNotNone(first_entry)
        self.assertEqual(first_entry.order_status.upper(), "PENDING")

    def test_failed_placement_creates_no_history_entry(self):
        OrderService.place_order(
            account_id=self.account.account_id,
            address="1 History Lane",
        )
        self.assertEqual(OrderStatusHistory.objects.count(), 0)


class OrderTrackingServiceTestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.catalog = _make_catalog()
        self.account = _make_account("trk_svc_001")
        self.cart = Cart.objects.create(account=self.account)
        self.menu_item = _make_menu_item(self.catalog, price_penny=2000, suffix="TrkSvc")
        _fill_cart(self.cart, self.menu_item, quantity=1)
        self.order, _ = OrderService.place_order(
            account_id=self.account.account_id,
            address="Service Test Address",
        )

    def test_get_tracking_returns_order_for_correct_account(self):
        order, history, error = OrderService.get_order_tracking(
            order_id=self.order.order_id,
            account_id=self.account.account_id,
        )
        self.assertIsNone(error)
        self.assertIsNotNone(order)
        self.assertEqual(order.order_id, self.order.order_id)

    def test_get_tracking_returns_none_for_wrong_account(self):
        """EC-UC7-01: another account must not see this order."""
        other_account = _make_account("trk_svc_other")
        order, history, error = OrderService.get_order_tracking(
            order_id=self.order.order_id,
            account_id=other_account.account_id,
        )
        self.assertIsNone(order)
        self.assertIsNotNone(error)

    def test_get_tracking_returns_none_for_nonexistent_order(self):
        """EC-UC7-02: non-existent order ID must produce an error."""
        order, history, error = OrderService.get_order_tracking(
            order_id="does-not-exist",
            account_id=self.account.account_id,
        )
        self.assertIsNone(order)
        self.assertIsNotNone(error)

    def test_get_tracking_returns_history_queryset(self):
        order, history, error = OrderService.get_order_tracking(
            order_id=self.order.order_id,
            account_id=self.account.account_id,
        )
        self.assertIsNone(error)
        self.assertIsNotNone(history)
        self.assertGreaterEqual(len(list(history)), 1)

    def test_history_entries_are_ordered_by_changed_at_ascending(self):
        _seed_history(self.order, "CONFIRMED", minutes_ago=5)
        _seed_history(self.order, "PREPARING", minutes_ago=2)

        _, history, _ = OrderService.get_order_tracking(
            order_id=self.order.order_id,
            account_id=self.account.account_id,
        )
        timestamps = [h.changed_at for h in history]
        self.assertEqual(timestamps, sorted(timestamps))


class TrackingAPITestCase(APITestCase):
    """
    Integration tests for GET /api/order/{orderId}/tracking/

    Covers:
      - Authentication guard
      - Response shape (contract fields)
      - Progress mapping for every status
      - currentStatus label mapping (uppercase DB → lowercase contract)
      - OUT_FOR_DELIVERY → "delivery" alias
      - estimatedTimeMinutes present and non-negative
      - History list ordering
      - History entry shape
      - Ownership isolation (EC-UC7-01)
      - Non-existent order ID (EC-UC7-02)
      - account_id cannot be injected via query param
    """

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _ensure_accounts_table()

    def setUp(self):
        self.client = APIClient()
        self.catalog = _make_catalog()
        self.menu_item = _make_menu_item(self.catalog, price_penny=1500, suffix="Trk")

        self.account_a = _make_account("trk_a")
        self.account_b = _make_account("trk_b")

        self.cart_a = Cart.objects.create(account=self.account_a)
        self.cart_b = Cart.objects.create(account=self.account_b)

        _fill_cart(self.cart_a, self.menu_item, quantity=2)
        self.order_a, _ = OrderService.place_order(
            account_id=self.account_a.account_id,
            address="42 Tracking Street",
        )

        _fill_cart(self.cart_b, self.menu_item, quantity=1)
        self.order_b, _ = OrderService.place_order(
            account_id=self.account_b.account_id,
            address="99 Other Road",
        )


    def _access_token_for(self, account: Accounts) -> str:
        refresh = RefreshToken()
        refresh["account_id"] = account.account_id
        refresh["email"] = account.email
        refresh["role"] = account.role
        refresh["display_name"] = account.display_name
        return str(refresh.access_token)

    def _authenticate(self, account: Accounts):
        self.client.credentials(
            HTTP_AUTHORIZATION=f"Bearer {self._access_token_for(account)}"
        )

    def _tracking_url(self, order_id: str) -> str:
        return f"/api/order/{order_id}/tracking/"



    def test_tracking_requires_authentication(self):
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    def test_tracking_invalid_token_rejected(self):
        self.client.credentials(HTTP_AUTHORIZATION="Bearer not.a.real.token")
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertIn(
            response.status_code,
            [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN],
        )

    def test_tracking_returns_200_for_own_order(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_tracking_response_has_all_required_fields(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        for field in ["orderId", "currentStatus", "progress",
                      "estimatedTimeMinutes", "history"]:
            self.assertIn(field, response.data, msg=f"Missing field: {field}")

    def test_tracking_order_id_matches_requested_order(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["orderId"], self.order_a.order_id)

    def test_tracking_history_is_a_list(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data["history"], list)

    def test_tracking_history_is_non_empty_after_placement(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data["history"]), 1)

    def test_tracking_history_entry_has_status_and_timestamp(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        entry = response.data["history"][0]
        self.assertIn("status", entry, "History entry missing 'status'")
        self.assertIn("timestamp", entry, "History entry missing 'timestamp'")

    def test_tracking_history_ordered_chronologically(self):
        _seed_history(self.order_a, "CONFIRMED", minutes_ago=10)
        _seed_history(self.order_a, "PREPARING", minutes_ago=5)

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        timestamps = [e["timestamp"] for e in response.data["history"]]
        self.assertEqual(
            timestamps,
            sorted(timestamps),
            "History must be sorted oldest-first.",
        )

    def test_tracking_current_status_is_lowercase_pending(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["currentStatus"], "pending")

    def test_tracking_current_status_confirmed(self):
        self.order_a.order_status = "CONFIRMED"
        self.order_a.save()
        _seed_history(self.order_a, "CONFIRMED")

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.data["currentStatus"], "confirmed")

    def test_tracking_current_status_preparing(self):
        self.order_a.order_status = "PREPARING"
        self.order_a.save()

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.data["currentStatus"], "preparing")

    def test_tracking_current_status_ready(self):
        self.order_a.order_status = "READY"
        self.order_a.save()

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.data["currentStatus"], "ready")

    def test_tracking_current_status_out_for_delivery_mapped_to_delivery(self):
        self.order_a.order_status = "OUT_FOR_DELIVERY"
        self.order_a.save()

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.data["currentStatus"], "delivery")

    def test_tracking_current_status_delivered(self):
        self.order_a.order_status = "DELIVERED"
        self.order_a.save()

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.data["currentStatus"], "delivered")

    def test_progress_is_0_for_pending(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(int(response.data["progress"]), 0)

    def test_progress_is_20_for_confirmed(self):
        self.order_a.order_status = "CONFIRMED"
        self.order_a.save()
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(int(response.data["progress"]), 20)

    def test_progress_is_50_for_preparing(self):
        self.order_a.order_status = "PREPARING"
        self.order_a.save()
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(int(response.data["progress"]), 50)

    def test_progress_is_70_for_ready(self):
        self.order_a.order_status = "READY"
        self.order_a.save()
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(int(response.data["progress"]), 70)

    def test_progress_is_90_for_out_for_delivery(self):
        self.order_a.order_status = "OUT_FOR_DELIVERY"
        self.order_a.save()
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(int(response.data["progress"]), 90)

    def test_progress_is_100_for_delivered(self):
        self.order_a.order_status = "DELIVERED"
        self.order_a.save()
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(int(response.data["progress"]), 100)

    def test_progress_is_within_0_to_100_range(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        prog = int(response.data["progress"])
        self.assertGreaterEqual(prog, 0)
        self.assertLessEqual(prog, 100)


    def test_estimated_time_is_non_negative_integer(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        eta = response.data["estimatedTimeMinutes"]
        self.assertIsInstance(eta, int)
        self.assertGreaterEqual(eta, 0)

    def test_estimated_time_is_zero_for_delivered_order(self):
        self.order_a.order_status = "DELIVERED"
        self.order_a.save()
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["estimatedTimeMinutes"], 0)

    def test_estimated_time_decreases_as_order_progresses(self):
        eta_by_status = {}
        for db_status in ["PENDING", "CONFIRMED", "PREPARING",
                          "READY", "OUT_FOR_DELIVERY", "DELIVERED"]:
            self.order_a.order_status = db_status
            self.order_a.save()
            self._authenticate(self.account_a)
            r = self.client.get(self._tracking_url(self.order_a.order_id))
            self.assertEqual(r.status_code, status.HTTP_200_OK)
            eta_by_status[db_status] = r.data["estimatedTimeMinutes"]

        ordered = ["PENDING", "CONFIRMED", "PREPARING",
                   "READY", "OUT_FOR_DELIVERY", "DELIVERED"]
        for i in range(len(ordered) - 1):
            self.assertGreaterEqual(
                eta_by_status[ordered[i]],
                eta_by_status[ordered[i + 1]],
                msg=(
                    f"ETA for {ordered[i]} ({eta_by_status[ordered[i]]}) must be "
                    f">= ETA for {ordered[i+1]} ({eta_by_status[ordered[i+1]]})"
                ),
            )



    def test_tracking_returns_404_for_other_accounts_order(self):
        self._authenticate(self.account_b)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND,
            "Cross-account order access must return 404, not 403.",
        )

    def test_tracking_404_for_other_account_does_not_leak_order_details(self):
        self._authenticate(self.account_b)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        response_text = str(response.data)
        self.assertNotIn(self.order_a.order_id, response_text)
        self.assertNotIn(self.account_a.account_id, response_text)

    def test_tracking_account_id_cannot_be_injected_via_query_param(self):
        self._authenticate(self.account_b)
        response = self.client.get(
            self._tracking_url(self.order_a.order_id),
            {"account_id": self.account_a.account_id},
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_tracking_returns_404_for_nonexistent_order_id(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url("ORD-FAKE-99999"))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_tracking_404_response_does_not_expose_internals(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url("ORD-DOES-NOT-EXIST"))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        response_text = str(response.data).lower()
        for forbidden in ["traceback", "exception", "django", "sql"]:
            self.assertNotIn(forbidden, response_text,
                             msg=f"Response must not expose '{forbidden}'")

    def test_tracking_404_body_contains_message_field(self):
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url("nonexistent-order"))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn("message", response.data)

    def test_tracking_endpoint_is_read_only_rejects_post(self):
        self._authenticate(self.account_a)
        response = self.client.post(
            self._tracking_url(self.order_a.order_id), {}, format="json"
        )
        self.assertIn(
            response.status_code,
            [status.HTTP_405_METHOD_NOT_ALLOWED, status.HTTP_404_NOT_FOUND],
        )

    def test_tracking_endpoint_is_read_only_rejects_put(self):
        self._authenticate(self.account_a)
        response = self.client.put(
            self._tracking_url(self.order_a.order_id), {}, format="json"
        )
        self.assertIn(
            response.status_code,
            [status.HTTP_405_METHOD_NOT_ALLOWED, status.HTTP_404_NOT_FOUND],
        )

    def test_tracking_endpoint_is_read_only_rejects_delete(self):
        self._authenticate(self.account_a)
        response = self.client.delete(self._tracking_url(self.order_a.order_id))
        self.assertIn(
            response.status_code,
            [status.HTTP_405_METHOD_NOT_ALLOWED, status.HTTP_404_NOT_FOUND],
        )

    def test_history_reflects_all_seeded_status_changes(self):
        _seed_history(self.order_a, "CONFIRMED", minutes_ago=15)
        _seed_history(self.order_a, "PREPARING", minutes_ago=10)
        _seed_history(self.order_a, "READY",     minutes_ago=5)
        self.order_a.order_status = "READY"
        self.order_a.save()

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data["history"]), 4)

    def test_history_status_values_are_lowercase_strings(self):
        _seed_history(self.order_a, "CONFIRMED", minutes_ago=5)
        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        for entry in response.data["history"]:
            self.assertEqual(
                entry["status"],
                entry["status"].lower(),
                "History status values must be lowercase.",
            )

    def test_history_out_for_delivery_label_is_delivery(self):
        _seed_history(self.order_a, "OUT_FOR_DELIVERY", minutes_ago=3)
        self.order_a.order_status = "OUT_FOR_DELIVERY"
        self.order_a.save()

        self._authenticate(self.account_a)
        response = self.client.get(self._tracking_url(self.order_a.order_id))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        labels = [e["status"] for e in response.data["history"]]
        self.assertIn(
            "delivery", labels,
            "OUT_FOR_DELIVERY history entry must appear as 'delivery'.",
        )
        self.assertNotIn(
            "out_for_delivery", labels,
            "Raw 'out_for_delivery' label must not leak into history.",
        )