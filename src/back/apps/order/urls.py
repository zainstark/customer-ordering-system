from django.urls import path
from .views import PlaceOrderView
app_name = 'order'
urlpatterns = [
    path('checkout/', PlaceOrderView.as_view(), name='place-order'),
]