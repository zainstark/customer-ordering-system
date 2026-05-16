from django.db import models

class Accounts(models.Model):
    account_id = models.TextField(primary_key=True, blank=True, null=False)
    display_name = models.TextField()
    email = models.TextField(unique=True)
    role = models.TextField()
    password_hash = models.TextField()
    phone_number = models.TextField(blank=True, null=True)
    active = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'accounts'

