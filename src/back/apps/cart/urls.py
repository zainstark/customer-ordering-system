"""
URL routing for cart app endpoints.

Maps URL patterns to view functions:
- GET /api/cart/ -> get_cart
- POST /api/cart/items/ -> add_item_to_cart
- PATCH /api/cart/items/{id}/ -> update_cart_item
- DELETE /api/cart/items/{id}/ -> remove_item_from_cart
- POST /api/cart/validate/ -> validate_cart
- DELETE /api/cart/ -> clear_cart
"""

from django.urls import path
from . import views

app_name = 'cart'

urlpatterns = [
    path('<str:cart_id>/', views.cart_detail, name='cart_detail'),
    path('<str:cart_id>/items/<str:cart_item_id>/', views.cart_item_detail, name='cart_item_detail'),
]
