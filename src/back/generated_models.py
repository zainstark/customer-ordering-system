# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.utils import timezone


class CustomerRole(models.TextChoices):
    CUSTOMER = "customer", "Customer"
    ADMIN = "admin", "Admin"


class OrderStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    CONFIRMED = "CONFIRMED", "Confirmed"
    PREPARING = "PREPARING", "Preparing"
    READY = "READY", "Ready"
    OUT_FOR_DELIVERY = "OUT_FOR_DELIVERY", "Out for delivery"
    DELIVERED = "DELIVERED", "Delivered"
    CANCELLED = "CANCELLED", "Cancelled"
    REFUNDED = "REFUNDED", "Refunded"
    FAILED = "FAILED", "Failed"


class PaymentMethod(models.TextChoices):
    CASH = "CASH", "Cash"
    CARD = "CARD", "Card"


class PaymentStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    AUTHORIZED = "AUTHORIZED", "Authorized"
    COMPLETED = "COMPLETED", "Completed"
    FAILED = "FAILED", "Failed"
    REFUNDED = "REFUNDED", "Refunded"
    CANCELLED = "CANCELLED", "Cancelled"


class DeliveryChannel(models.TextChoices):
    EMAIL = "EMAIL", "Email"
    SMS = "SMS", "SMS"
    IN_APP = "IN_APP", "In App"
    WHATSAPP = "WHATSAPP", "WhatsApp"


class DeliveryStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    SENT = "SENT", "Sent"
    FAILED = "FAILED", "Failed"
    DELIVERED = "DELIVERED", "Delivered"


class CustomerAccounts(models.Model):
    account_id = models.TextField(primary_key=True)
    display_name = models.TextField()
    email = models.TextField(unique=True)
    role = models.TextField(
        choices=CustomerRole.choices,
        default=CustomerRole.CUSTOMER,
    )
    password_hash = models.TextField()
    phone_number = models.TextField(blank=True, null=True)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "customer_accounts"


class Sessions(models.Model):
    session_id = models.TextField(primary_key=True)
    account = models.ForeignKey(
        CustomerAccounts,
        on_delete=models.CASCADE,
    )
    created_at = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField()
    active = models.BooleanField(default=True)

    class Meta:
        db_table = "sessions"


class MenuCatalogs(models.Model):
    catalog_id = models.TextField(primary_key=True)
    name = models.TextField()
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "menu_catalogs"


class Categories(models.Model):
    category_id = models.TextField(primary_key=True)
    category_name = models.TextField()
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "categories"


class MenuItems(models.Model):
    menu_item_id = models.TextField(primary_key=True)
    catalog = models.ForeignKey(
        MenuCatalogs,
        on_delete=models.CASCADE,
    )
    name = models.TextField()
    description = models.TextField(blank=True, null=True)
    price_penny = models.IntegerField()
    category = models.ForeignKey(
        Categories,
        on_delete=models.CASCADE,
    )
    available = models.BooleanField(default=True)
    image_url = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "menu_items"


class Carts(models.Model):
    cart_id = models.TextField(primary_key=True)
    account = models.OneToOneField(
        CustomerAccounts,
        on_delete=models.CASCADE,
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "carts"


class CartItems(models.Model):
    cart_item_id = models.TextField(primary_key=True)
    cart = models.ForeignKey(
        Carts,
        on_delete=models.CASCADE,
    )
    menu_item = models.ForeignKey(
        "MenuItems",
        on_delete=models.CASCADE,
    )
    quantity = models.IntegerField()
    unit_price_snapshot = models.IntegerField(
        blank=True,
        null=True,
    )
    line_total = models.IntegerField(
        blank=True,
        null=True,
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "cart_items"


class Orders(models.Model):
    order_id = models.TextField(primary_key=True)
    account = models.ForeignKey(
        CustomerAccounts,
        on_delete=models.CASCADE,
    )
    total_amount = models.IntegerField()
    placed_at = models.DateTimeField(default=timezone.now)
    order_status = models.TextField(
        choices=OrderStatus.choices,
    )
    confirmed_at = models.DateTimeField(
        blank=True,
        null=True,
    )
    updated_at = models.DateTimeField(default=timezone.now)
    address = models.TextField()

    class Meta:
        db_table = "orders"


class OrderItems(models.Model):
    order_item_id = models.TextField(primary_key=True)
    order = models.ForeignKey(
        Orders,
        on_delete=models.CASCADE,
    )
    menu_item = models.ForeignKey(
        MenuItems,
        on_delete=models.CASCADE,
    )
    item_name_snapshot = models.TextField()
    item_description_snapshot = models.TextField(
        blank=True,
        null=True,
    )
    unit_price_snapshot = models.IntegerField()
    quantity = models.IntegerField()
    line_total = models.IntegerField()

    class Meta:
        db_table = "order_items"


class Payments(models.Model):
    payment_id = models.TextField(primary_key=True)
    order = models.ForeignKey(
        Orders,
        on_delete=models.CASCADE,
    )
    amount = models.IntegerField()
    initiated_at = models.DateTimeField(default=timezone.now)
    processed_at = models.DateTimeField(
        blank=True,
        null=True,
    )
    payment_method = models.TextField(
        choices=PaymentMethod.choices,
    )
    payment_status = models.TextField(
        choices=PaymentStatus.choices,
    )

    class Meta:
        db_table = "payments"


class Transactions(models.Model):
    transaction_id = models.TextField(primary_key=True)
    payment = models.ForeignKey(
        Payments,
        on_delete=models.CASCADE,
    )
    gateway_reference = models.TextField(
        blank=True,
        null=True,
    )
    authorization_code = models.TextField(
        blank=True,
        null=True,
    )
    processed_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "transactions"


class OrderStatusHistory(models.Model):
    history_id = models.TextField(primary_key=True)
    order = models.ForeignKey(
        Orders,
        on_delete=models.CASCADE,
    )
    order_status = models.TextField(
        choices=OrderStatus.choices,
    )
    note = models.TextField(blank=True, null=True)
    changed_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "order_status_history"


class NotificationMessages(models.Model):
    message_id = models.TextField(primary_key=True)
    account = models.ForeignKey(
        CustomerAccounts,
        on_delete=models.CASCADE,
    )
    order = models.ForeignKey(
        Orders,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
    )
    subject = models.TextField(
        blank=True,
        null=True,
    )
    body = models.TextField(
        blank=True,
        null=True,
    )
    delivery_channel = models.TextField(
        choices=DeliveryChannel.choices,
    )
    delivery_status = models.TextField(
        choices=DeliveryStatus.choices,
    )
    created_at = models.DateTimeField(default=timezone.now)
    sent_at = models.DateTimeField(
        blank=True,
        null=True,
    )

    class Meta:
        db_table = "notification_messages"
