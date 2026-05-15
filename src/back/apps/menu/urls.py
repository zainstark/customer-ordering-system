from django.urls import path
from .views import MenuCategoriesView

app_name = 'menu'

urlpatterns = [
    path('categories/', MenuCategoriesView.as_view(), name='menu-categories'),
]