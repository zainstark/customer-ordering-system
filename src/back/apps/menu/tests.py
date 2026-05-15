from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth.models import User
from apps.menu.models import MenuCatalog, MenuItem
from apps.menu.serializers import MenuCatalogSerializer, MenuItemSerializer
from apps.menu.services import MenuService

class MenuModelTestCase(TestCase):
    def setUp(self):
        self.catalog = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )
        self.item = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog,
            name='Coffee',
            description='Hot coffee',
            price_penny=500,  # $5.00
            category='Hot Drinks',
            available=True,
            image_url='http://example.com/coffee.jpg'
        )

    def test_menu_catalog_creation(self):
        self.assertEqual(self.catalog.name, 'Beverages')
        self.assertTrue(self.catalog.active)

    def test_menu_item_creation(self):
        self.assertEqual(self.item.name, 'Coffee')
        self.assertEqual(self.item.price, 5.0)

class MenuSerializerTestCase(TestCase):
    def setUp(self):
        self.catalog = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )
        self.item = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog,
            name='Coffee',
            description='Hot coffee',
            price_penny=500,
            category='Hot Drinks',
            available=True,
            image_url='http://example.com/coffee.jpg'
        )

    def test_menu_item_serializer(self):
        serializer = MenuItemSerializer(self.item)
        data = serializer.data
        self.assertEqual(data['id'], 'item1')
        self.assertEqual(data['title'], 'Coffee')
        self.assertEqual(data['subtitle'], 'Hot coffee')
        self.assertEqual(data['unitPrice'], 5.0)
        self.assertEqual(data['imageUrl'], 'http://example.com/coffee.jpg')

    def test_menu_catalog_serializer(self):
        serializer = MenuCatalogSerializer(self.catalog)
        data = serializer.data
        self.assertEqual(data['id'], 'cat1')
        self.assertEqual(data['label'], 'Beverages')
        self.assertEqual(len(data['menuItems']), 1)
        self.assertEqual(data['menuItems'][0]['title'], 'Coffee')

class MenuServiceTestCase(TestCase):
    def setUp(self):
        self.catalog1 = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )
        self.catalog2 = MenuCatalog.objects.create(
            catalog_id='cat2',
            name='Food'
        )
        self.item1 = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog1,
            name='Coffee',
            description='Hot coffee',
            price_penny=500,
            available=True
        )
        self.item2 = MenuItem.objects.create(
            menu_item_id='item2',
            catalog=self.catalog2,
            name='Pizza',
            description='Cheese pizza',
            price_penny=1500,
            available=True
        )
        self.unavailable_item = MenuItem.objects.create(
            menu_item_id='item3',
            catalog=self.catalog1,
            name='Tea',
            price_penny=300,
            available=False
        )

    def test_get_catalogs_basic(self):
        catalogs = MenuService.get_catalogs()
        self.assertEqual(len(catalogs), 2)
        # Check items are filtered to available
        bev_catalog = catalogs.get(catalog_id='cat1')
        self.assertEqual(bev_catalog.menu_items.count(), 1)  # Only Coffee, not Tea

    def test_get_catalogs_with_search(self):
        catalogs = MenuService.get_catalogs(search='pizza')
        self.assertEqual(len(catalogs), 1)
        self.assertEqual(catalogs[0].catalog_id, 'cat2')

    def test_get_catalogs_with_category_filter(self):
        catalogs = MenuService.get_catalogs(category_filter='beverage')
        self.assertEqual(len(catalogs), 1)
        self.assertEqual(catalogs[0].catalog_id, 'cat1')

    def test_get_catalogs_no_results(self):
        catalogs = MenuService.get_catalogs(search='nonexistent')
        self.assertEqual(len(catalogs), 0)

class MenuAPITestCase(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.catalog = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )
        self.item = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog,
            name='Coffee',
            price_penny=500,
            available=True
        )

    def test_get_menu_categories_authenticated(self):
        self.client.login(username='testuser', password='testpass')
        response = self.client.get('/menu/categories/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['label'], 'Beverages')

    def test_get_menu_categories_unauthenticated(self):
        response = self.client.get('/menu/categories/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_get_menu_categories_with_search(self):
        self.client.login(username='testuser', password='testpass')
        response = self.client.get('/menu/categories/?search=coffee')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_get_menu_categories_no_results(self):
        self.client.login(username='testuser', password='testpass')
        response = self.client.get('/menu/categories/?search=nonexistent')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_get_menu_categories_empty_menu(self):
        # Remove all catalogs
        MenuCatalog.objects.all().delete()
        self.client.login(username='testuser', password='testpass')
        response = self.client.get('/menu/categories/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)
