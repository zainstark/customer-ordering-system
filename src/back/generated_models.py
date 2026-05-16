# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class CartItems(models.Model):
    cart_item_id = models.TextField(primary_key=True, blank=True, null=False)
    cart = models.ForeignKey('Carts', models.DO_NOTHING)
    menu_item = models.ForeignKey('MenuItems', models.DO_NOTHING)
    quantity = models.IntegerField()
    unit_price_snapshot = models.IntegerField(blank=True, null=True)
    line_total = models.IntegerField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'cart_items'


class Carts(models.Model):
    cart_id = models.TextField(primary_key=True, blank=True, null=False)
    account = models.OneToOneField('Accounts', models.DO_NOTHING)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'carts'


class Categories(models.Model):
    category_id = models.TextField(primary_key=True, blank=True, null=False)
    category_name = models.TextField()
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'categories'


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


class MenuCatalogs(models.Model):
    catalog_id = models.TextField(primary_key=True, blank=True, null=False)
    name = models.TextField()
    active = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'menu_catalogs'


class MenuItems(models.Model):
    menu_item_id = models.TextField(primary_key=True, blank=True, null=False)
    catalog = models.ForeignKey(MenuCatalogs, models.DO_NOTHING)
    name = models.TextField()
    description = models.TextField(blank=True, null=True)
    price_penny = models.IntegerField()
    category = models.ForeignKey(Categories, models.DO_NOTHING)
    available = models.BooleanField()
    image_url = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'menu_items'


class NotificationMessages(models.Model):
    message_id = models.TextField(primary_key=True, blank=True, null=False)
    account = models.ForeignKey(Accounts, models.DO_NOTHING)
    order = models.ForeignKey('Orders', models.DO_NOTHING, blank=True, null=True)
    subject = models.TextField(blank=True, null=True)
    body = models.TextField(blank=True, null=True)
    delivery_channel = models.TextField()
    delivery_status = models.TextField()
    created_at = models.DateTimeField()
    sent_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'notification_messages'


class OrderItems(models.Model):
    order_item_id = models.TextField(primary_key=True, blank=True, null=False)
    order = models.ForeignKey('Orders', models.DO_NOTHING)
    menu_item = models.ForeignKey(MenuItems, models.DO_NOTHING)
    item_name_snapshot = models.TextField()
    item_description_snapshot = models.TextField(blank=True, null=True)
    unit_price_snapshot = models.IntegerField()
    quantity = models.IntegerField()
    line_total = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'order_items'


class OrderStatusHistory(models.Model):
    history_id = models.TextField(primary_key=True, blank=True, null=False)
    order = models.ForeignKey('Orders', models.DO_NOTHING)
    order_status = models.TextField()
    note = models.TextField(blank=True, null=True)
    changed_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'order_status_history'


class Orders(models.Model):
    order_id = models.TextField(primary_key=True, blank=True, null=False)
    account = models.ForeignKey(Accounts, models.DO_NOTHING)
    total_amount = models.IntegerField()
    placed_at = models.DateTimeField()
    order_status = models.TextField()
    confirmed_at = models.DateTimeField(blank=True, null=True)
    updated_at = models.DateTimeField()
    address = models.TextField()

    class Meta:
        managed = False
        db_table = 'orders'


class Payments(models.Model):
    payment_id = models.TextField(primary_key=True, blank=True, null=False)
    order = models.ForeignKey(Orders, models.DO_NOTHING)
    amount = models.IntegerField()
    initiated_at = models.DateTimeField()
    processed_at = models.DateTimeField(blank=True, null=True)
    payment_method = models.TextField()
    payment_status = models.TextField()

    class Meta:
        managed = False
        db_table = 'payments'



class Transactions(models.Model):
    transaction_id = models.TextField(primary_key=True, blank=True, null=False)
    payment = models.ForeignKey(Payments, models.DO_NOTHING)
    gateway_reference = models.TextField(blank=True, null=True)
    authorization_code = models.TextField(blank=True, null=True)
    processed_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'transactions'
