from rest_framework import serializers
from .models import MenuCatalog, MenuItem

class MenuItemSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='menu_item_id', read_only=True)
    title = serializers.CharField(source='name', read_only=True)
    subtitle = serializers.CharField(source='description', allow_null=True, read_only=True)
    unitPrice = serializers.SerializerMethodField()
    imageUrl = serializers.CharField(source='image_url', allow_null=True, read_only=True)
    category = serializers.SerializerMethodField()

    def get_unitPrice(self, obj):
        return obj.price  # Returns price in dollars as float

    def get_category(self, obj):
        # Prefer normalized Category FK name when available; fall back to legacy string
        try:
            if getattr(obj, 'category_fk', None):
                return obj.category_fk.name
        except Exception:
            pass
        return obj.category

    class Meta:
        model = MenuItem
        fields = ['id', 'title', 'subtitle', 'unitPrice', 'imageUrl', 'category']

class MenuCatalogSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='catalog_id', read_only=True)
    label = serializers.CharField(source='name', read_only=True)
    menuItems = serializers.SerializerMethodField()

    def get_menuItems(self, obj):
        # Filter only available items
        available_items = obj.menu_items.filter(available=True)
        return MenuItemSerializer(available_items, many=True).data

    class Meta:
        model = MenuCatalog
        fields = ['id', 'label', 'menuItems']