#!/usr/bin/env python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.menu.models import MenuCatalog, Category, MenuItem
from apps.authentication.models import Accounts

print("MenuCatalogs:", MenuCatalog.objects.count())
print("Categories:", Category.objects.count())
print("MenuItems:", MenuItem.objects.count())
print("Accounts:", Accounts.objects.count())

print("\nCategories:")
for cat in Category.objects.all():
    print(f"  - {cat.name} ({cat.category_id})")

print("\nAccounts:")
for acc in Accounts.objects.all():
    print(f"  - {acc.email} ({acc.account_id})")

print("\nMenu Items (first 5):")
for item in MenuItem.objects.all()[:5]:
    print(f"  - {item.name}: ${item.price}")
