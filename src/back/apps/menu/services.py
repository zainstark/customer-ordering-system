from django.db.models import Q, Prefetch
from .models import MenuCatalog, MenuItem

class MenuService:
    @staticmethod
    def get_catalogs(search=None, category_filter=None):
        """
        Retrieve active menu catalogs with their available menu items.
        Supports optional search and category filtering.

        Args:
            search (str): Search term to filter items by name or description
            category_filter (str): Filter catalogs by name containing this term

        Returns:
            QuerySet of MenuCatalog with prefetched menu_items
        """
        catalogs = MenuCatalog.objects.filter(active=True)

        # Apply category filter if provided
        if category_filter:
            catalogs = catalogs.filter(name__icontains=category_filter)

        # Prefetch available menu items
        catalogs = catalogs.prefetch_related(
            Prefetch('menu_items', queryset=MenuItem.objects.filter(available=True))
        )

        # Apply search filter if provided
        if search:
            catalogs = catalogs.filter(
                Q(menu_items__name__icontains=search) |
                Q(menu_items__description__icontains=search)
            ).distinct()

        # Order catalogs by name
        catalogs = catalogs.order_by('name')

        return catalogs