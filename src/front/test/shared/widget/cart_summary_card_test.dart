import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/features/widgets/cart_summary_card.dart';
import 'package:go_router/go_router.dart';

class _FakeSummaryState {
  const _FakeSummaryState({
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.total,
  });

  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double total;
}

void main() {
  const summaryState = _FakeSummaryState(
    subtotal: 25.5,
    deliveryFee: 2.99,
    taxes: 2.25,
    total: 30.74,
  );

  testWidgets('renders subtotal, fees, taxes and total from state object', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CartSummaryCard(state: summaryState, button: true),
        ),
      ),
    );

    expect(find.text('Order summary'), findsOneWidget);
    expect(find.text(r'$25.50'), findsOneWidget);
    expect(find.text(r'$2.99'), findsOneWidget);
    expect(find.text(r'$2.25'), findsOneWidget);
    expect(find.text(r'$30.74'), findsOneWidget);
  });

  testWidgets('hides checkout button when button flag is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CartSummaryCard(state: summaryState, button: false),
        ),
      ),
    );

    expect(find.text('Proceed to checkout'), findsNothing);
  });

  testWidgets('shows checkout button and navigates to checkout route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: RoutesPath.cart,
      routes: [
        GoRoute(
          path: RoutesPath.cart,
          builder: (context, state) => const Scaffold(
            body: CartSummaryCard(state: summaryState, button: true),
          ),
        ),
        GoRoute(
          path: RoutesPath.checkout,
          builder: (context, state) =>
              const Scaffold(body: Text('checkout-screen')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Proceed to checkout'), findsOneWidget);

    await tester.tap(find.text('Proceed to checkout'));
    await tester.pumpAndSettle();

    expect(find.text('checkout-screen'), findsOneWidget);
  });
}
