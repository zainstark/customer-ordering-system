import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_state.dart';
import 'package:frontend/features/authentication/presentation/screens/signup_screen.dart';
import 'package:frontend/features/authentication/presentation/screens/login_screen.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/screens/cart_screen.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/menu/presentation/screens/menu_screen.dart';
import 'package:frontend/features/orders/presentation/cubit/order_tracking_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/screens/order_tracking_screen.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/presentation/screens/orders_screen.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:frontend/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:frontend/features/checkout/presentation/screens/payment_failure_screen.dart';
import 'package:frontend/features/checkout/presentation/screens/payment_processing_screen.dart';
import 'package:frontend/features/checkout/presentation/screens/payment_success_screen.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:frontend/features/notifications/presentation/pages/notifications_page.dart';
import 'package:frontend/features/shell/presentation/widgets/app_shell_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    getIt<AuthCubit>().stream,
  ),
    initialLocation: RoutesPath.login,
    redirect: _handleRedirect,
    routes: [
      // ✅ One top-level ShellRoute provides AuthCubit to ALL routes
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => getIt<AuthCubit>()..initialize(),
          child: child, // child is the whole subtree — auth pages AND app pages
        ),
        routes: [
          GoRoute(
            path: RoutesPath.signup,
            name: RoutesName.signup,
            builder: (_, __) => const SignupScreen(),
          ),
          GoRoute(
            path: RoutesPath.login,
            name: RoutesName.login,
            builder: (_, __) => const LoginScreen(),
          ),
          // Nested ShellRoute MUST have its own builder
          ShellRoute(
            builder: (context, state, child) =>
                AppShellScaffold(currentPath: state.uri.path, child: child),
            routes: [
              GoRoute(
                path: RoutesPath.menu,
                name: RoutesName.menu,
                builder: (context, _) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<MenuCubit>()..loadMenu()),
                    BlocProvider(create: (context) => getIt<CartCubit>()),
                  ],
                  child: const MenuScreen(),
                ),
              ),
              GoRoute(
                path: RoutesPath.cart,
                name: RoutesName.cart,
                builder: (context, _) => BlocProvider(
                  create: (_) => getIt<CartCubit>()..loadCart(),
                  child: const CartScreen(),
                ),
              ),
              GoRoute(
                path: RoutesPath.orders,
                name: RoutesName.orders,
                builder: (context, _) => BlocProvider(
                  create: (_) => getIt<OrdersCubit>()..loadOrders(),
                  child: const OrdersScreen(),
                ),
              ),
              ShellRoute(
                builder: (context, state, child) => BlocProvider(
                  create: (_) => getIt<CheckoutCubit>()..loadCheckout(),
                  child: child,
                ),
                routes: [
                  GoRoute(
                    path: RoutesPath.checkout,
                    name: RoutesName.checkout,
                    builder: (context, _) => const CheckoutScreen(),
                  ),
                  GoRoute(
                    path: RoutesPath.paymentProcessing,
                    name: RoutesName.paymentProcessing,
                    builder: (context, _) => const PaymentProcessingScreen(),
                  ),
                  GoRoute(
                    path: RoutesPath.paymentSuccess,
                    name: RoutesName.paymentSuccess,
                    builder: (context, _) => const PaymentSuccessScreen(),
                  ),
                  GoRoute(
                    path: RoutesPath.paymentFailure,
                    name: RoutesName.paymentFailure,
                    builder: (context, _) => const PaymentFailureScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: RoutesPath.orderTracking,
                name: RoutesName.orderTracking,
                builder: (context, state) {
                  final orderId = state.pathParameters['id']!;
                  final orderSummary = state.extra as OrderItemEntity;
                  return BlocProvider(
                    create: (_) => getIt<OrderTrackingCubit>(),
                    child: OrderTrackingScreen(orderId: orderId, orderSummary: orderSummary),
                  );
                },
              ),
              GoRoute(
                path: RoutesPath.notifications,
                name: RoutesName.notifications,
                builder: (context, _) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<NotificationCubit>()),
                    BlocProvider(
                      create: (_) => getIt<NotificationBadgeCubit>(),
                    ),
                  ],
                  child: const NotificationsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authStatus = getIt<AuthCubit>().state.status;
    final isAuthenticated = authStatus == AuthStatus.authenticated;
    final isOnAuthPage =
        state.matchedLocation == RoutesPath.login ||
        state.matchedLocation == RoutesPath.signup;

    if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
      return null;
    }

    if (!isAuthenticated && !isOnAuthPage) return RoutesPath.login;

    if (isAuthenticated && isOnAuthPage) return RoutesPath.menu;

    return null;
  }
}



class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();

    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
