from django.urls import path
from . import views

urlpatterns = [
    path('list', views.list_notifications, name='notifications-list'),
    path('unread-count', views.unread_count, name='notifications-unread-count'),
    path('<str:message_id>/read', views.mark_as_read, name='notifications-mark-as-read'),
    path('mark-all-read', views.mark_all_read, name='notifications-mark-all-read'),
]
