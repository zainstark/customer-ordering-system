"""Cart service layer for cart business logic and validation."""

from typing import Callable, Dict, List, Optional, Tuple

from django.db import transaction

from apps.authentication.models import Accounts
from apps.menu.models import MenuItem

from .models import Cart, CartItem


# Dummy menu items data (until menu app is built and database is populated)
DUMMY_MENU_ITEMS = {
    'menu_001': {
        'name': 'Margherita Pizza',
        'description': 'Classic pizza with tomato, mozzarella, and basil',
        'price': 1500,  # in pennies ($15.00)
        'available': True,
        'category': 'Pizza',
        'imageUrl': 'https://images.example.com/menu/margherita-pizza.jpg',
    },
    'menu_002': {
        'name': 'Pepperoni Pizza',
        'description': 'Pizza with pepperoni and extra cheese',
        'price': 1700,  # in pennies ($17.00)
        'available': True,
        'category': 'Pizza',
        'imageUrl': 'https://images.example.com/menu/pepperoni-pizza.jpg',
    },
    'menu_003': {
        'name': 'Caesar Salad',
        'description': 'Fresh romaine lettuce with parmesan and croutons',
        'price': 800,  # in pennies ($8.00)
        'available': True,
        'category': 'Salad',
        'imageUrl': 'https://images.example.com/menu/caesar-salad.jpg',
    },
    'menu_004': {
        'name': 'Garlic Bread',
        'description': 'Crispy garlic bread with herbs',
        'price': 400,  # in pennies ($4.00)
        'available': True,
        'category': 'Sides',
        'imageUrl': 'https://images.example.com/menu/garlic-bread.jpg',
    },
    'menu_005': {
        'name': 'Coca Cola',
        'description': 'Cold soft drink',
        'price': 250,  # in pennies ($2.50)
        'available': True,
        'category': 'Beverages',
        'imageUrl': 'https://images.example.com/menu/coca-cola.jpg',
    },
}


class CartService:
    """Service layer for cart operations."""

    _menu_provider: Optional[Callable[[str], Optional[Dict]]] = None

    @classmethod
    def set_menu_provider(cls, provider: Optional[Callable[[str], Optional[Dict]]]):
        """Allow tests to inject deterministic menu fixtures."""
        cls._menu_provider = provider

    @staticmethod
    def _get_menu_item_from_db(menu_item_id: str) -> Optional[Dict]:
        try:
            menu_item = MenuItem.objects.get(menu_item_id=menu_item_id)
        except MenuItem.DoesNotExist:
            return None

        return {
            'menu_item_id': menu_item.menu_item_id,
            'name': menu_item.name,
            'description': menu_item.description,
            'price_penny': menu_item.price_penny,
            'available': menu_item.available,
            'image_url': menu_item.image_url,
        }

    @staticmethod
    def get_or_create_cart(account_id: str) -> Cart:
        """Get existing cart for account or create a new one."""
        account = Accounts.objects.get(account_id=account_id)
        cart, _ = Cart.objects.get_or_create(account=account)
        return cart

    @staticmethod
    def _get_menu_item(menu_item_id: str) -> Optional[Dict]:
        """Retrieve menu item using injected provider, DB lookup, then test fallback."""
        if CartService._menu_provider is not None:
            return CartService._menu_provider(menu_item_id)

        menu_item = CartService._get_menu_item_from_db(menu_item_id)
        if menu_item is not None:
            return menu_item

        return DUMMY_MENU_ITEMS.get(menu_item_id)

    @staticmethod
    def add_item_to_cart(
        cart_id: str,
        menu_item_id: str,
        quantity: int,
    ) -> Tuple[Optional[CartItem], Optional[str]]:
        """
        Add item to cart with validation.
        
        Validates:
        - Menu item exists
        - Menu item is available
        - Quantity is positive
        
        Args:
            cart_id: Cart ID
            menu_item_id: Menu item ID to add
            quantity: Quantity to add
            
        Returns:
            Tuple of (CartItem or None, error_message or None)
        """
        # Validate quantity
        if not isinstance(quantity, int) or quantity <= 0:
            return None, "Quantity must be a positive integer"
        
        # Validate menu item exists.
        menu_item = CartService._get_menu_item(menu_item_id)
        if not menu_item:
            return None, f"Menu item {menu_item_id} not found"

        # Validate item is available.
        if not menu_item.get('available', False):
            return None, f"Menu item {menu_item['name']} is out of stock"

        try:
            cart = Cart.objects.get(cart_id=cart_id)
        except Cart.DoesNotExist:
            return None, f"Cart {cart_id} not found"

        unit_price_snapshot = menu_item.get('price_penny')
        if unit_price_snapshot is None:
            # Support existing dummy fixtures using `price` while standardizing on `price_penny`.
            unit_price_snapshot = menu_item.get('price')

        if unit_price_snapshot is None:
            return None, f"Menu item {menu_item_id} has no valid price"

        # Add or update item in cart.
        cart_item, created = CartItem.objects.get_or_create(
            cart=cart,
            menu_item_id=menu_item_id,
            defaults={
                'quantity': quantity,
                'unit_price_snapshot': unit_price_snapshot,
            }
        )

        if not created:
            # Item already in cart, increase quantity.
            cart_item.quantity += quantity
            cart_item.save()

        cart.save()
        return cart_item, None

    @staticmethod
    def update_item_quantity(
        cart_item_id: str,
        new_quantity: int,
    ) -> Tuple[Optional[CartItem], Optional[str]]:
        """
        Update quantity of an item in cart.
        
        Validates:
        - Quantity is positive
        - CartItem exists
        
        Args:
            cart_item_id: Cart item ID
            new_quantity: New quantity value
            
        Returns:
            Tuple of (CartItem or None, error_message or None)
        """
        # Validate quantity.
        if not isinstance(new_quantity, int) or new_quantity <= 0:
            return None, "Quantity must be a positive integer"

        try:
            cart_item = CartItem.objects.get(cart_item_id=cart_item_id)
        except CartItem.DoesNotExist:
            return None, f"Cart item {cart_item_id} not found"

        cart_item.quantity = new_quantity
        cart_item.save()
        cart_item.cart.save()

        return cart_item, None

    @staticmethod
    def remove_item_from_cart(cart_item_id: str) -> Tuple[bool, Optional[str]]:
        """
        Remove item from cart.
        
        Args:
            cart_item_id: Cart item ID to remove
            
        Returns:
            Tuple of (success: bool, error_message or None)
        """
        try:
            cart_item = CartItem.objects.get(cart_item_id=cart_item_id)
            cart = cart_item.cart
            cart_item.delete()
            cart.save()
            return True, None
        except CartItem.DoesNotExist:
            return False, f"Cart item {cart_item_id} not found"

    @staticmethod
    def get_cart_with_items(cart_id: str) -> Optional[Dict]:
        """
        Retrieve cart with all its items.
        
        Args:
            cart_id: Cart ID
            
        Returns:
            Dict with cart data and items, or None if cart not found
        """
        try:
            cart = Cart.objects.get(cart_id=cart_id)
        except Cart.DoesNotExist:
            return None
        
        items = CartItem.objects.filter(cart=cart).values(
            'cart_item_id',
            'menu_item_id',
            'quantity',
            'unit_price_snapshot',
            'line_total',
            'created_at',
            'updated_at',
        )
        
        cart_total = cart.get_cart_total()
        item_count = cart.get_item_count()
        
        return {
            'cart_id': cart.cart_id,
            'account_id': cart.account_id,
            'items': list(items),
            'item_count': item_count,
            'cart_total': cart_total,
            'created_at': cart.created_at,
            'updated_at': cart.updated_at,
        }

    @staticmethod
    def validate_cart_items(cart_id: str) -> Tuple[bool, List[Dict]]:
        """
        Validate all items in cart (availability and pricing).
        
        Returns items that have issues (out of stock, etc).
        
        Args:
            cart_id: Cart ID
            
        Returns:
            Tuple of (is_valid: bool, issues: List of problem items)
        """
        try:
            cart = Cart.objects.get(cart_id=cart_id)
        except Cart.DoesNotExist:
            return False, [{'error': 'Cart not found'}]
        
        cart_items = CartItem.objects.filter(cart=cart)
        issues = []
        
        for item in cart_items:
            menu_item = CartService._get_menu_item(item.menu_item_id)

            if not menu_item:
                issues.append({
                    'cart_item_id': item.cart_item_id,
                    'menu_item_id': item.menu_item_id,
                    'issue': 'Menu item no longer exists',
                })
            elif not menu_item.get('available', False):
                issues.append({
                    'cart_item_id': item.cart_item_id,
                    'menu_item_id': item.menu_item_id,
                    'name': menu_item['name'],
                    'issue': 'Item is out of stock',
                })
            elif (
                menu_item.get('price_penny', menu_item.get('price'))
                != item.unit_price_snapshot
            ):
                issues.append({
                    'cart_item_id': item.cart_item_id,
                    'menu_item_id': item.menu_item_id,
                    'name': menu_item['name'],
                    'issue': 'Price has changed',
                    'old_price': item.unit_price_snapshot,
                    'new_price': menu_item.get('price_penny', menu_item.get('price')),
                })

        is_valid = len(issues) == 0
        return is_valid, issues

    @staticmethod
    @transaction.atomic
    def clear_cart(cart_id: str) -> Tuple[bool, Optional[str]]:
        """
        Remove all items from cart.
        
        Args:
            cart_id: Cart ID
            
        Returns:
            Tuple of (success: bool, error_message or None)
        """
        try:
            cart = Cart.objects.get(cart_id=cart_id)
            cart.items.all().delete()
            cart.save()
            return True, None
        except Cart.DoesNotExist:
            return False, f"Cart {cart_id} not found"

    @staticmethod
    def calculate_cart_total(cart_id: str) -> Tuple[Optional[int], Optional[str]]:
        """
        Calculate total amount in cart.
        
        Args:
            cart_id: Cart ID
            
        Returns:
            Tuple of (total in pennies or None, error_message or None)
        """
        try:
            cart = Cart.objects.get(cart_id=cart_id)
            return cart.get_cart_total(), None
        except Cart.DoesNotExist:
            return None, f"Cart {cart_id} not found"
