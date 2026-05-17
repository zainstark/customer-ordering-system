from rest_framework import serializers
from django.conf import settings
from .models import MenuCatalog, MenuItem

class MenuItemSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='menu_item_id', read_only=True)
    title = serializers.CharField(source='name', read_only=True)
    subtitle = serializers.CharField(source='description', allow_null=True, read_only=True)
    unitPrice = serializers.SerializerMethodField()
    imageUrl = serializers.SerializerMethodField()
    category = serializers.SerializerMethodField()

    def get_unitPrice(self, obj):
        return obj.price  # Returns price in dollars as float

    def get_imageUrl(self, obj):
        """Return a full media URL for image filenames stored in DB.

        - If `image_url` is empty -> None
        - If it already looks like a URL (http/https) -> return as-is
        - Otherwise build absolute URI: request.build_absolute_uri(MEDIA_URL + filename)
          If request not available, fall back to settings.MEDIA_URL + filename (relative)
        """
        filename = getattr(obj, 'image_url', None)
        if not filename:
            return None
        # If already a full URL, return it
        if isinstance(filename, str) and (filename.startswith('http://') or filename.startswith('https://')):
            return filename

        request = self.context.get('request') if hasattr(self, 'context') else None
        media_path = settings.MEDIA_URL or '/media/'
        # Ensure leading slash on media_path
        if not media_path.endswith('/'):
            media_path = media_path + '/'
        relative = f"{media_path.lstrip('/')}{filename}" if media_path.startswith('/') else f"{media_path}{filename}"

        if request:
            return request.build_absolute_uri(media_path + filename)
        # Fallback: return media URL combined with filename (may be relative)
        return media_path + filename

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
        # Pass down the serializer context (which includes `request`) so nested serializer
        # can build absolute media URLs when needed.
        return MenuItemSerializer(available_items, many=True, context=self.context).data

    class Meta:
        model = MenuCatalog
        fields = ['id', 'label', 'menuItems']