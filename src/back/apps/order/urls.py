"""
URL routing for the order app.

Include this in the root urls.py with:
    path('api/order/', include('apps.order.urls'))

Resulting endpoints:
    GET  /api/order/        -> list_orders
    POST /api/order/place/  -> place_order
"""

from django.urls import path

from apps.order import views

app_name = "order"

urlpatterns = [
    path("", views.list_orders, name="list_orders"),
    path("place/", views.place_order, name="place_order"),
    path("<str:order_id>/tracking/", views.order_tracking, name="order_tracking"),
]