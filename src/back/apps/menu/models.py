from django.db import models

class MenuCatalog(models.Model):
    catalog_id = models.CharField(max_length=255, primary_key=True)
    name = models.CharField(max_length=255)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menu_catalogs'

    def __str__(self):
        return self.name


class Category(models.Model):
    category_id = models.CharField(max_length=255, primary_key=True)
    name = models.CharField(max_length=255, unique=True, db_column='category_name')
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'categories'

    def __str__(self):
        return self.name

class MenuItem(models.Model):
    menu_item_id = models.CharField(max_length=255, primary_key=True)
    catalog = models.ForeignKey(MenuCatalog, on_delete=models.CASCADE, related_name='menu_items', db_column='catalog_id')
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    price_penny = models.IntegerField()  # Price in pennies to avoid floating point issues
    # Normalized FK to the Category model
    category_fk = models.ForeignKey(
        Category,
        null=True,
        blank=True,
        on_delete=models.DO_NOTHING,
        related_name='menu_items',
        db_column='category_id'
    )
    available = models.BooleanField(default=True)
    image_url = models.URLField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menu_items'

    def __str__(self):
        return self.name

    @property
    def price(self):
        """Return price in dollars (float)"""
        return self.price_penny / 100.0
