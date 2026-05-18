import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/cart/presentation/screens/cart_screen.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartCubit extends MockCubit<CartState> implements CartCubit {}

class _FakeCartState extends Fake implements CartState {}

CartItemEntity _item({int quantity = 2}) {
  return CartItemEntity(
    id: 'cart-item-1',
    cartId: 'cart-1',
    menuItemId: 'menu-1',
    title: 'Burger',
    subtitle: 'Cheese Burger',
    unitPrice: 10,
    quantity: quantity,
    imageUrl: 'https://example.com/image.png',
  );
}

Widget _buildApp(CartCubit cubit) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<CartCubit>.value(
        value: cubit,
        child: const CartScreen(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCartState());
  });

  group('CartScreen', () {
    late _MockCartCubit cubit;

    setUp(() {
      cubit = _MockCartCubit();
      whenListen(cubit, const Stream<CartState>.empty());
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      when(() => cubit.state).thenReturn(
        const CartState(
          accountId: 'acc-1',
          models: [],
          status: CartRequestStatus.loading,
        ),
      );

      await tester.pumpWidget(_buildApp(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state and retries load', (tester) async {
      when(() => cubit.state).thenReturn(
        const CartState(
          accountId: 'acc-1',
          models: [],
          status: CartRequestStatus.error,
          errorMessage: 'Failed to load cart',
        ),
      );
      when(() => cubit.loadCart()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));

      expect(find.text('Failed to load cart'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      final retryButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      retryButton.onPressed?.call();
      await tester.pump();

      verify(() => cubit.loadCart()).called(1);
    });

    testWidgets('shows empty cart message for successful empty result', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(
        const CartState(
          accountId: 'acc-1',
          models: [],
          status: CartRequestStatus.success,
        ),
      );
      when(() => cubit.loadCart()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));

      expect(find.text('Your cart is empty.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders cart content on success', (tester) async {
      when(() => cubit.state).thenReturn(
        CartState(
          accountId: 'acc-1',
          models: [_item()],
          status: CartRequestStatus.success,
        ),
      );

      await tester.pumpWidget(_buildApp(cubit));

      expect(find.text('Your cart'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Order summary'), findsOneWidget);
      expect(find.text('Proceed to checkout'), findsOneWidget);
    });
  });

  group('CartItemCard', () {
    testWidgets('calls increment, decrement and remove callbacks', (
      tester,
    ) async {
      var incrementCalls = 0;
      var decrementCalls = 0;
      var removeCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemCard(
              model: _item(quantity: 1),
              onIncrement: () => incrementCalls += 1,
              onDecrement: () => decrementCalls += 1,
              onRemove: () => removeCalls += 1,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.delete_outline));

      expect(incrementCalls, 1);
      expect(decrementCalls, 1);
      expect(removeCalls, 1);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
