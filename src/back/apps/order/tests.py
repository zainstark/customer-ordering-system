from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth.models import User
from unittest.mock import patch

from .services import OrderService, PriceMismatchError, ItemUnavailableError
from .models import Order

class OrderServiceTests(TestCase):
    """Testing the business logic"""
    
    def setUp(self):
        self.service = OrderService()
        self.account_id = "acc_123"

    def test_service_creates_order_successfully(self):
        cart_items = [
            {"id": "MI-1", "name": "Burger", "price_cents": 1000, "quantity": 1}
        ]
        order = self.service.create_order(self.account_id, cart_items, 1000)
        self.assertEqual(order.total_amount, 1000)
        self.assertEqual(order.order_status, "PENDING")
        self.assertEqual(order.items.count(), 1)

    def test_service_fails_on_empty_cart(self):
        with self.assertRaisesMessage(ValueError, "Order cannot be placed with an empty cart."):
            self.service.create_order(self.account_id, [], 0)

    def test_service_fails_on_price_mismatch(self):
        cart_items = [{"id": "MI-1", "name": "Burger", "price_cents": 1000, "quantity": 1}]
        with self.assertRaises(PriceMismatchError):
            self.service.create_order(self.account_id, cart_items, 500) # User claims it costs 500


class OrderAPITests(TestCase):
    """Testing the API Contract"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='password')
        self.client.force_authenticate(user=self.user)
        self.url = reverse('order:place-order')

    def test_api_success_matches_flutter_contract(self):
        payload = {
            "expected_total_cents": 1500,
            "payment_method": "CARD",
            "items": [
                {"id": "MI-1", "name": "Burger", "price_cents": 1000, "quantity": 1},
                {"id": "MI-2", "name": "Fries", "price_cents": 500, "quantity": 1}
            ]
        }
        response = self.client.post(self.url, payload, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # EXACT MATCH TO FLUTTER CONTRACT: { id, accountId, orderId, status, placedAt, totalAmount, progress }
        data = response.json()
        self.assertIn('id', data)
        self.assertIn('accountId', data)
        self.assertIn('orderId', data)
        self.assertIn('status', data)
        self.assertIn('placedAt', data)
        self.assertIn('totalAmount', data)
        self.assertIn('progress', data)
        
        self.assertEqual(data['status'], 'PENDING')
        self.assertEqual(data['progress'], 0.1) # Progress bar float for Flutter

    def test_api_empty_cart_returns_flutter_error_model(self):
        payload = {"expected_total_cents": 0, "payment_method": "CARD", "items": []}
        response = self.client.post(self.url, payload, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # MUST use "message" for Flutter's AppException mapping
        self.assertIn('message', response.json()) 

    def test_api_price_mismatch_returns_flutter_error_model(self):
        payload = {
            "expected_total_cents": 500,
            "payment_method": "CARD",
            "items": [{"id": "MI-1", "name": "Burger", "price_cents": 1000, "quantity": 1}]
        }
        response = self.client.post(self.url, payload, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertIn('message', response.json()) # MUST use "message"