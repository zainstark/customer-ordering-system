import 'package:flutter/material.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RoutesPath.menu,
    redirect: _handleRedirect,
    routes: [
      GoRoute(path: RoutesPath.menu, name: RoutesName.menu),
      GoRoute(path: RoutesPath.cart, name: RoutesName.cart),
      GoRoute(path: RoutesPath.orders, name: RoutesName.orders),
    ],
  );

  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    // TODO: No redirection logic for now, but this is where you can add authentication checks or other conditions to redirect users to different routes.
    return null;
  }
}
