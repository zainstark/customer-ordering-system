from django.urls import path
from apps.order.views import PlaceOrderView, TrackOrderView

app_name = 'order'

urlpatterns = [
    # UC4 Endpoint
    path('place/', PlaceOrderView.as_view(), name='place-order'),

    # UC7 Endpoint
    path('<str:order_id>/track/', TrackOrderView.as_view(), name='track-order'),
]