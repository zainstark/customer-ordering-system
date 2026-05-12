import 'package:flutter/material.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/Core/router/app_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/theme/app_theme.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('menu cubit changes selected category and filters dishes', () {
    final cubit = MenuCubit();
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

  test('cart cubit updates quantity and totals', () {
    final cubit = CartCubit();
    final item = cubit.state.models.first;
    final initialQuantity = item.quantity;

    cubit.incrementItem(item.id);
    expect(cubit.state.models.first.quantity, initialQuantity + 1);

    cubit.decrementItem(item.id);
    expect(cubit.state.models.first.quantity, initialQuantity);
    expect(cubit.state.total, greaterThan(0));
  });

  test('orders cubit switches between active and past tabs', () {
    final cubit = OrdersCubit();
    expect(cubit.state.selectedTab, OrdersTab.active);

    cubit.changeTab(OrdersTab.past);
    expect(cubit.state.selectedTab, OrdersTab.past);
    expect(cubit.state.visibleOrders, cubit.state.pastOrders);
  });
}
