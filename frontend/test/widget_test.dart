import 'package:flutter/material.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/theme/app_theme.dart';
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
}
