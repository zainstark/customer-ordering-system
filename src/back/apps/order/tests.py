from django.contrib.auth.models import User
import uuid
from unittest.mock import patch
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from django.core.cache import cache

from apps.order.services import OrderService
from apps.order.models import Order, OrderItem


class PlaceOrderValidationTests(TestCase):
    
    def setUp(self):
        self.account_id = "user-1"

    @patch('apps.order.services.OrderService._get_cart_and_items')
    def test_validation_empty_cart(self, mock_get_cart):
        mock_get_cart.return_value = (None, [])
        
        with self.assertRaisesMessage(Exception, "Order cannot be placed with an empty cart."):
            OrderService.create_order(account_id=self.account_id, idempotency_key=str(uuid.uuid4()))
        
        self.assertEqual(Order.objects.count(), 0)

    @patch('apps.order.services.OrderService._get_cart_and_items')
    @patch('apps.order.services.OrderService._get_menu_items_map')
    def test_validation_item_unavailable(self, mock_get_menu, mock_get_cart):
        class MockCartItem: menu_item_id = "item-1"; quantity = 1; unit_price_snapshot = 1000
        class MockMenuItem: available = False # <--- Item is out of stock!
        
        mock_get_cart.return_value = (None, [MockCartItem()])
        mock_get_menu.return_value = {"item-1": MockMenuItem()}

        with self.assertRaisesMessage(Exception, "Item item-1 is currently out of stock."):
            OrderService.create_order(account_id=self.account_id, idempotency_key=str(uuid.uuid4()))
            
        self.assertEqual(Order.objects.count(), 0)

    @patch('apps.order.services.OrderService._get_cart_and_items')
    @patch('apps.order.services.OrderService._get_menu_items_map')
    def test_validation_price_changed(self, mock_get_menu, mock_get_cart):
        class MockCartItem: menu_item_id = "item-1"; quantity = 1; unit_price_snapshot = 1000 # Old price
        class MockMenuItem: available = True; price_penny = 1500 # <--- New price in DB
        
        mock_get_cart.return_value = (None, [MockCartItem()])
        mock_get_menu.return_value = {"item-1": MockMenuItem()}

        with self.assertRaisesMessage(Exception, "Price for item-1 has changed. Please review your cart."):
            OrderService.create_order(account_id=self.account_id, idempotency_key=str(uuid.uuid4()))

        self.assertEqual(Order.objects.count(), 0)


class PlaceOrderAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.url = reverse('order:place-order') 
        
        self.user = User.objects.create_user(username='testcustomer', password='password')
        self.client.force_authenticate(user=self.user)
        # -----------------------------------------------------------

        self.service_patcher = patch('apps.order.views.OrderService.create_order')
        self.mock_create_order = self.service_patcher.start()
        
        self.mock_order = Order(
            order_id="ORD-123", 
            account_id=str(self.user.id), 
            total_amount=1500, 
            order_status="PENDING"
        )
        self.mock_create_order.return_value = (self.mock_order, True) 

    def tearDown(self):
        self.service_patcher.stop()
        cache.clear()
      
    def test_api_place_order_success(self):
        response = self.client.post(self.url, HTTP_IDEMPOTENCY_KEY=str(uuid.uuid4()))
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('order_id', response.data)
        self.assertEqual(response.data['order_status'], 'PENDING')
        self.mock_create_order.assert_called_once()

    def test_api_idempotency_duplicate_request(self):
        self.mock_create_order.return_value = (self.mock_order, False)
        
        idempotency_key = str(uuid.uuid4())
        response = self.client.post(self.url, HTTP_IDEMPOTENCY_KEY=idempotency_key)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['order_id'], "ORD-123")

    def test_api_missing_idempotency_key(self):
        response = self.client.post(self.url) 
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Idempotency-Key header is required", response.data['detail'])

    def test_api_tampered_payload_ignored(self):
        payload = {"total_amount": 1, "items": [{"price": 1}]}
        response = self.client.post(self.url, data=payload, format='json', HTTP_IDEMPOTENCY_KEY=str(uuid.uuid4()))
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
        args, kwargs = self.mock_create_order.call_args
        self.assertNotIn("total_amount", kwargs)
        
    def test_api_handles_validation_error(self):
        from rest_framework.exceptions import ValidationError
        self.mock_create_order.side_effect = ValidationError("Custom validation message")
        
        response = self.client.post(self.url, HTTP_IDEMPOTENCY_KEY=str(uuid.uuid4()))
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Custom validation message", str(response.data))