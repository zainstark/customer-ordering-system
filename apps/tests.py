from apps.services import OrderService, PriceMismatchError

from django.test import TestCase
from django.core.exceptions import ValidationError
import pytest

class OrderServiceTest(TestCase):
    def setUp(self):
        self.service = OrderService()
        self.user_id = 1

    def test_create_order_fails_on_empty_cart(self):
        """Edge Case: EC-UC4-01"""
        empty_cart_items = []
        with pytest.raises(ValueError, match="Order cannot be placed with an empty cart"):
            self.service.create_order(self.user_id, empty_cart_items, 100.00)

    def test_create_order_fails_on_price_mismatch(self):
        """Edge Case: EC-UC4-04"""
        cart_items = [{'id': 'MI-1', 'price': 10.0, 'quantity': 1, 'name': 'Burger'}]
        # User claims total is 5.0, but server calculates 10.0
        with pytest.raises(PriceMismatchError):
            self.service.create_order(self.user_id, cart_items, 5.00)