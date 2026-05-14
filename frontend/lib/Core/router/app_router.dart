import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/screens/cart_screen.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/menu/presentation/screens/menu_screen.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/screens/orders_screen.dart';
import 'package:frontend/features/shell/presentation/widgets/app_shell_scaffold.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RoutesPath.menu,
    redirect: _handleRedirect,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShellScaffold(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: RoutesPath.menu,
            name: RoutesName.menu,
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<MenuCubit>()..loadMenu(),
              child: const MenuScreen(),
            ),
          ),
          GoRoute(
            path: RoutesPath.cart,
            name: RoutesName.cart,
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<CartCubit>()..loadCart(),
              child: const CartScreen(),
            ),
          ),
          GoRoute(
            path: RoutesPath.orders,
            name: RoutesName.orders,
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<OrdersCubit>()..loadOrders(),
              child: const OrdersScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    // TODO: No redirection logic for now, but this is where you can add authentication checks or other conditions to redirect users to different routes.
    return null;
  }
}
