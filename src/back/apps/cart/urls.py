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
    path('', views.get_cart, name='get_cart'),
    path('validate/', views.validate_cart, name='validate_cart'),
    path('clear/', views.clear_cart, name='clear_cart'),
    path('items/', views.add_item_to_cart, name='add_item'),
    path('items/<str:cart_item_id>/', views.update_cart_item, name='update_item'),
    path('items/<str:cart_item_id>/delete/', views.remove_item_from_cart, name='remove_item'),
]
