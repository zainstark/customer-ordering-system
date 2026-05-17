from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status

from apps.authentication.models import Accounts
from apps.menu.models import (
    MenuCatalog,
    MenuItem,
    Category,
)
from apps.menu.serializers import (
    MenuCatalogSerializer,
    MenuItemSerializer,
)
from apps.menu.services import MenuService


class MenuModelTestCase(TestCase):
    def setUp(self):
        self.catalog = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )

        self.category = Category.objects.create(
            category_id='burger-category',
            name='Burger'
        )

        self.item = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog,
            category_fk=self.category,
            name='Coffee',
            description='Hot coffee',
            price_penny=500,
            available=True,
            image_url='http://example.com/coffee.jpg'
        )

    def test_menu_catalog_creation(self):
        self.assertEqual(
            self.catalog.name,
            'Beverages'
        )
        self.assertTrue(self.catalog.active)

    def test_menu_item_creation(self):
        self.assertEqual(
            self.item.name,
            'Coffee'
        )

        self.assertEqual(
            self.item.price,
            5.0
        )

        self.assertEqual(
            self.item.category_fk.category_id,
            self.category.category_id
        )


class MenuSerializerTestCase(TestCase):
    def setUp(self):
        self.catalog = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )

        self.category = Category.objects.create(
            category_id='burger-category',
            name='Burger'
        )

        self.item = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog,
            category_fk=self.category,
            name='Coffee',
            description='Hot coffee',
            price_penny=500,
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
        self.assertEqual(
            data['imageUrl'],
            'http://example.com/coffee.jpg'
        )

        self.assertEqual(
            data['category'],
            self.category.name
        )

    def test_menu_catalog_serializer(self):
        serializer = MenuCatalogSerializer(
            self.catalog
        )

        data = serializer.data

        self.assertEqual(
            data['id'],
            'cat1'
        )

        self.assertEqual(
            data['label'],
            'Beverages'
        )

        self.assertEqual(
            len(data['menuItems']),
            1
        )

        self.assertEqual(
            data['menuItems'][0]['title'],
            'Coffee'
        )

        self.assertEqual(
            data['menuItems'][0]['category'],
            self.category.name
        )


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

        self.category = Category.objects.create(
            category_id='general-category',
            name='General'
        )

        self.item1 = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog1,
            category_fk=self.category,
            name='Coffee',
            description='Hot coffee',
            price_penny=500,
            available=True
        )

        self.item2 = MenuItem.objects.create(
            menu_item_id='item2',
            catalog=self.catalog2,
            category_fk=self.category,
            name='Pizza',
            description='Cheese pizza',
            price_penny=1500,
            available=True
        )

        self.unavailable_item = MenuItem.objects.create(
            menu_item_id='item3',
            catalog=self.catalog1,
            category_fk=self.category,
            name='Tea',
            price_penny=300,
            available=False
        )

    def test_get_catalogs_basic(self):
        catalogs = MenuService.get_catalogs()

        self.assertEqual(
            len(catalogs),
            2
        )

        bev_catalog = catalogs.get(
            catalog_id='cat1'
        )

        self.assertEqual(
            bev_catalog.menu_items.count(),
            1
        )

    def test_get_catalogs_with_search(self):
        catalogs = MenuService.get_catalogs(
            search='pizza'
        )

        self.assertEqual(
            len(catalogs),
            1
        )

        self.assertEqual(
            catalogs[0].catalog_id,
            'cat2'
        )

    def test_get_catalogs_with_category_filter(self):
        catalogs = MenuService.get_catalogs(
            category_filter='beverage'
        )

        self.assertEqual(
            len(catalogs),
            1
        )

        self.assertEqual(
            catalogs[0].catalog_id,
            'cat1'
        )

    def test_get_catalogs_no_results(self):
        catalogs = MenuService.get_catalogs(
            search='nonexistent'
        )

        self.assertEqual(
            len(catalogs),
            0
        )


class MenuAPITestCase(APITestCase):
    def setUp(self):
        self.user = Accounts(
            account_id='test-uuid',
            email='test@test.com',
            role='customer',
            active=True,
        )

        self.catalog = MenuCatalog.objects.create(
            catalog_id='cat1',
            name='Beverages'
        )

        self.category = Category.objects.create(
            category_id='burger-category',
            name='Burger'
        )

        self.item = MenuItem.objects.create(
            menu_item_id='item1',
            catalog=self.catalog,
            category_fk=self.category,
            name='Coffee',
            price_penny=500,
            available=True
        )

    def test_get_menu_categories_authenticated(self):
        self.client.force_authenticate(
            user=self.user
        )

        response = self.client.get(
            '/menu/categories/'
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )

        self.assertEqual(
            len(response.data),
            1
        )

    def test_get_menu_categories_unauthenticated(self):
        response = self.client.get(
            '/menu/categories/'
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_403_FORBIDDEN
        )

    def test_get_menu_categories_with_search(self):
        self.client.force_authenticate(
            user=self.user
        )

        response = self.client.get(
            '/menu/categories/?search=coffee'
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )

    def test_get_menu_categories_no_results(self):
        self.client.force_authenticate(
            user=self.user
        )

        response = self.client.get(
            '/menu/categories/?search=nonexistent'
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )

        self.assertEqual(
            len(response.data),
            0
        )

    def test_get_menu_categories_empty_menu(self):
        MenuCatalog.objects.all().delete()

        self.client.force_authenticate(
            user=self.user
        )

        response = self.client.get(
            '/menu/categories/'
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )

        self.assertEqual(
            len(response.data),
            0
        )
