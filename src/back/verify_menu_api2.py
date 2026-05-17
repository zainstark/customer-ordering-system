#!/usr/bin/env python
import os
import django
import json

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from rest_framework.test import APIClient
from apps.authentication.models import Accounts

client = APIClient()
user = Accounts.objects.filter(email='john@example.com').first() or Accounts.objects.first()
client.force_authenticate(user=user)
client.defaults['HTTP_HOST'] = '127.0.0.1:8000'
resp = client.get('/menu/categories/')
print(json.dumps(resp.json(), indent=2))
