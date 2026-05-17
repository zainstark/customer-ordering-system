from django.urls import path

from apps.payments import views

app_name = 'payments'

urlpatterns = [
    path('create-session/', views.create_payment_session, name='create_payment_session'),
    path('<str:payment_id>/status/', views.get_payment_status, name='get_payment_status'),
    path('<str:payment_id>/retry/', views.retry_payment, name='retry_payment'),
    path('webhook/', views.payment_webhook, name='payment_webhook'),
]
