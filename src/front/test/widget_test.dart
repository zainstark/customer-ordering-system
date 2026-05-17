import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/Core/router/app_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/theme/app_theme.dart';
import 'package:frontend/features/cart/data/models/cart_item_model.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';
import 'package:frontend/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/menu/data/models/menu_category_model.dart';
import 'package:frontend/features/menu/data/models/menu_item_model.dart';
import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';
import 'package:frontend/features/menu/domain/repositories/menu_repository.dart';
import 'package:frontend/features/menu/domain/usecases/get_menu_categories_usecase.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/orders/data/models/order_item_model.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/repositories/orders_repository.dart';
import 'package:frontend/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/order_cubit.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_order_summary_card.dart';
import 'package:frontend/features/payment/presentation/screens/payment_screen.dart';

class _FakeMenuRepository implements MenuRepository {
  @override
  Future<List<MenuCategoryEntity>> getMenuCategories() async {
    return const [
      MenuCategoryModel(
        id: 'burgers',
        label: 'Burgers',
        menuItems: [
          MenuItemModel(
            id: 'd1',
            categoryId: 'burgers',
            title: 'The Royal Wagyu',
            description: 'desc',
            price: 17.5,
            available: true,
            rating: 4.8,
            imageUrl: 'https://example.com/wagyu.jpg',
          ),
        ],
      ),
      MenuCategoryModel(
        id: 'pizza',
        label: 'Pizza',
        menuItems: [
          MenuItemModel(
            id: 'd2',
            categoryId: 'pizza',
            title: 'Margherita',
            description: 'desc',
            price: 12.0,
            available: true,
            rating: 4.5,
            imageUrl: 'https://example.com/pizza.jpg',
          ),
        ],
      ),
    ];
  }
}

class _FakeCartRepository implements CartRepository {
  List<CartItemModel> _items = [
    CartItemModel(
      id: 'c1',
      cartId: 'CRT-1001',
      menuItemId: 'MI-100',
      title: 'Burger',
      subtitle: 'Double patty',
      unitPrice: 10.0,
      quantity: 1,
      imageUrl: 'https://example.com/burger.jpg',
    ),
  ];

  @override
  Future<List<CartItemEntity>> getCartItems({required String accountId}) async {
    return _items;
  }

  @override
  Future<List<CartItemEntity>> addItem({
    required String accountId,
    required String menuItemId,
    required int quantity,
  }) async {
    _items.add(
      CartItemModel(
        id: 'c${_items.length + 1}',
        cartId: 'CRT-1001',
        menuItemId: menuItemId,
        title: 'Item $menuItemId',
        subtitle: 'Description',
        unitPrice: 10.0,
        quantity: quantity,
        imageUrl: 'https://example.com/item.jpg',
      ),
    );
    return _items;
  }

  @override
  Future<List<CartItemEntity>> removeItem({required String cartItemId}) async {
    _items = _items.where((item) => item.id != cartItemId).toList();
    return _items;
  }

  @override
  Future<List<CartItemEntity>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    _items = _items.map((item) {
      if (item.id != cartItemId) return item;
      return item.copyWith(quantity: quantity);
    }).toList();
    return _items;
  }
}

class _FakeOrdersRepository implements OrdersRepository {
  @override
  Future<List<OrderItemEntity>> getOrders() async {
    return [
      OrderItemModel(
        id: 'o1',
        accountId: 'ACC-100',
        orderId: 'ORD-1',
        status: 'PREPARING',
        placedAt: DateTime(2026, 5, 1),
        totalAmount: 20.0,
        progress: 0.5,
        items: [],
      ),
      OrderItemModel(
        id: 'o2',
        accountId: 'ACC-100',
        orderId: 'ORD-2',
        status: 'DELIVERED',
        placedAt: DateTime(2026, 4, 1),
        totalAmount: 15.0,
        progress: 1,
        items: [],
      ),
    ];
  }

  @override
  Future<OrderItemEntity> placeOrder({required String address}) async {
    return OrderItemModel(
      id: 'o3',
      accountId: 'ACC-100',
      orderId: 'ORD-3',
      status: 'PENDING',
      placedAt: DateTime(2026, 5, 17),
      totalAmount: 42.0,
      progress: 0.1,
      items: [],
    );
  }
  
  @override
  Future<OrderItemEntity> placeOrder({required String address}) {
    // TODO: implement placeOrder
    throw UnimplementedError();
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('route names and paths are correctly configured', () {
    expect(RoutesPath.menu, '/menu');
    expect(RoutesPath.cart, '/cart');
    expect(RoutesPath.orders, '/orders');

    expect(RoutesName.menu, 'menu');
    expect(RoutesName.cart, 'cart');
    expect(RoutesName.orders, 'orders');
  });

  test('app theme builders return expected base configuration', () {
    final lightTheme = appLightTheme();
    final darkTheme = appDarkTheme();

    expect(lightTheme.useMaterial3, isTrue);
    expect(lightTheme.brightness, Brightness.light);

    expect(darkTheme.useMaterial3, isTrue);
    expect(darkTheme.brightness, Brightness.dark);
  });

  test('dependency setup registers DioClient as singleton', () {
    setupDependencies();

    expect(getIt.isRegistered<DioClient>(), isTrue);
    expect(identical(getIt<DioClient>(), getIt<DioClient>()), isTrue);
  });

  test('app router starts from menu route', () {
    final location = AppRouter.router.routeInformationProvider.value.uri.path;
    expect(location, RoutesPath.menu);
  });

  testWidgets('current UI renders the shell and feature navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    setupDependencies();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Whatever'), findsOneWidget);
    expect(find.text('Menu'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Cart'), findsWidgets);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Orders').last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Cart').last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  test('menu cubit changes selected category and filters dishes', () async {
    final cubit = MenuCubit(GetMenuCategoriesUseCase(_FakeMenuRepository()));
    await cubit.loadMenu();
    final initialCategory = cubit.state.selectedCategoryId;
    final nextCategory = cubit.state.categories
        .firstWhere((category) => category.id != initialCategory)
        .id;

    cubit.selectCategory(nextCategory);

    expect(cubit.state.selectedCategoryId, nextCategory);
    expect(
      cubit.state.filteredDishes.every(
        (dish) => dish.categoryId == nextCategory,
      ),
      isTrue,
    );
  });

  test('cart cubit updates quantity and totals', () async {
    final repo = _FakeCartRepository();
    final cubit = CartCubit(
      AddCartItemUseCase(repo),
      GetCartItemsUseCase(repo),
      UpdateCartItemQuantityUseCase(repo),
      RemoveCartItemUseCase(repo),
    );
    await cubit.loadCart();
    final item = cubit.state.models.first;
    final initialQuantity = item.quantity;

    cubit.incrementItem(item.id);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.models.first.quantity, initialQuantity + 1);

    cubit.decrementItem(item.id);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.models.first.quantity, initialQuantity);
    expect(cubit.state.total, greaterThan(0));
  });

  test('orders cubit switches between active and past tabs', () async {
    final cubit = OrdersCubit(GetOrdersUseCase(_FakeOrdersRepository()));
    await cubit.loadOrders();
    expect(cubit.state.selectedTab, OrdersTab.active);

    cubit.changeTab(OrdersTab.past);
    expect(cubit.state.selectedTab, OrdersTab.past);
    expect(cubit.state.visibleOrders, cubit.state.pastOrders);
  });

  testWidgets('proceed to checkout creates order and navigates to payment', (tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  // create fakes
  final orderRepo = _FakeOrdersRepository();
  final placeOrderUseCase = PlaceOrderUseCase(orderRepo);
  final orderCubit = OrderCubit(placeOrderUseCase);

  final cartRepo = _FakeCartRepository();
  final cartCubit = CartCubit(
    AddCartItemUseCase(cartRepo),
    GetCartItemsUseCase(cartRepo),
    UpdateCartItemQuantityUseCase(cartRepo),
    RemoveCartItemUseCase(cartRepo),
  );
  await cartCubit.loadCart();

  // register order cubit in service locator used by widget
  await getIt.reset();
  getIt.registerSingleton<OrderCubit>(orderCubit);

  await tester.pumpWidget(MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cartCubit),
        BlocProvider.value(value: orderCubit),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          body: CartOrderSummaryCard(state: cartCubit.state),
        ),
      ),
    ),
  ));

  await tester.pumpAndSettle();

  // Ensure the button exists and tap
  expect(find.text('Proceed to checkout'), findsOneWidget);
  await tester.tap(find.text('Proceed to checkout'));
  await tester.pumpAndSettle();

  // Payment screen should be pushed and show amount from fake order
  expect(find.textContaining('Amount:'), findsOneWidget);
  expect(find.text('Amount: \$42.00'), findsOneWidget);
  });
}
