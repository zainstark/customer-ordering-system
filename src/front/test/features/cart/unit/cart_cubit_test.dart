import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class _MockGetCartItemsUseCase extends Mock implements GetCartItemsUseCase {}

class _MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class _MockRemoveCartItemUseCase extends Mock
    implements RemoveCartItemUseCase {}

CartItemEntity _item({
  String id = 'cart-item-1',
  int quantity = 2,
  double unitPrice = 10,
}) {
  return CartItemEntity(
    id: id,
    cartId: 'cart-1',
    menuItemId: 'menu-1',
    title: 'Burger',
    subtitle: 'Cheese Burger',
    unitPrice: unitPrice,
    quantity: quantity,
    imageUrl: 'https://example.com/image.png',
  );
}

void main() {
  group('CartState', () {
    test('computes subtotal, taxes and total from items', () {
      const delivery = 2.99;
      final state = CartState(
        accountId: 'acc-1',
        models: [
          _item(quantity: 2, unitPrice: 10),
          _item(id: 'cart-item-2', quantity: 1, unitPrice: 5),
        ],
      );

      expect(state.subtotal, 25);
      expect(state.deliveryFee, delivery);
      expect(state.taxes, closeTo(2.25, 0.0001));
      expect(state.total, closeTo(30.24, 0.0001));
    });

    test('copyWith clears error when clearErrorMessage is true', () {
      final state = CartState(
        accountId: 'acc-1',
        models: const [],
        status: CartRequestStatus.error,
        errorMessage: 'failed',
      );

      final updated = state.copyWith(
        status: CartRequestStatus.success,
        clearErrorMessage: true,
      );

      expect(updated.status, CartRequestStatus.success);
      expect(updated.errorMessage, isNull);
    });
  });

  group('CartCubit', () {
    late _MockAddCartItemUseCase addUseCase;
    late _MockGetCartItemsUseCase getUseCase;
    late _MockUpdateCartItemQuantityUseCase updateUseCase;
    late _MockRemoveCartItemUseCase removeUseCase;

    setUp(() {
      addUseCase = _MockAddCartItemUseCase();
      getUseCase = _MockGetCartItemsUseCase();
      updateUseCase = _MockUpdateCartItemQuantityUseCase();
      removeUseCase = _MockRemoveCartItemUseCase();
    });

    CartCubit buildCubit() {
      return CartCubit(addUseCase, getUseCase, updateUseCase, removeUseCase);
    }

    blocTest<CartCubit, CartState>(
      'loadCart emits loading then success when request succeeds',
      build: () {
        when(
          () => getUseCase.call(accountId: any(named: 'accountId')),
        ).thenAnswer((_) async => [_item()]);
        return buildCubit();
      },
      act: (cubit) => cubit.loadCart(accountId: 'acc-2'),
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.loading)
            .having((s) => s.accountId, 'accountId', 'acc-2')
            .having((s) => s.errorMessage, 'error', isNull),
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.success)
            .having((s) => s.models.length, 'models', 1)
            .having((s) => s.errorMessage, 'error', isNull),
      ],
      verify: (_) {
        verify(() => getUseCase.call(accountId: 'acc-2')).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'loadCart emits loading then error when request fails',
      build: () {
        when(
          () => getUseCase.call(accountId: any(named: 'accountId')),
        ).thenThrow(Exception('load failed'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadCart(),
      expect: () => [
        isA<CartState>().having(
          (s) => s.status,
          'status',
          CartRequestStatus.loading,
        ),
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('load failed'),
            ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'addItem emits success with updated models',
      build: () {
        when(
          () => addUseCase.call(
            accountId: any(named: 'accountId'),
            menuItemId: any(named: 'menuItemId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => [_item(quantity: 3)]);
        return buildCubit();
      },
      act: (cubit) => cubit.addItem(menuItemId: 'menu-2', quantity: 1),
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.success)
            .having((s) => s.models.first.quantity, 'quantity', 3),
      ],
      verify: (_) {
        verify(
          () => addUseCase.call(
            accountId: 'test_account_001',
            menuItemId: 'menu-2',
            quantity: 1,
          ),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'addItem emits error when use case throws',
      build: () {
        when(
          () => addUseCase.call(
            accountId: any(named: 'accountId'),
            menuItemId: any(named: 'menuItemId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(Exception('out of stock'));
        return buildCubit();
      },
      act: (cubit) => cubit.addItem(menuItemId: 'menu-2', quantity: 1),
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('out of stock'),
            ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'invalid add quantity is forwarded and reported as error',
      build: () {
        when(
          () => addUseCase.call(
            accountId: any(named: 'accountId'),
            menuItemId: any(named: 'menuItemId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(Exception('Quantity must be at least 1.'));
        return buildCubit();
      },
      act: (cubit) => cubit.addItem(menuItemId: 'menu-2', quantity: 0),
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Quantity must be at least 1'),
            ),
      ],
      verify: (_) {
        verify(
          () => addUseCase.call(
            accountId: 'test_account_001',
            menuItemId: 'menu-2',
            quantity: 0,
          ),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'incrementItem increases quantity for existing item',
      build: () {
        when(
          () => updateUseCase.call(
            cartItemId: any(named: 'cartItemId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => [_item(quantity: 3)]);
        return buildCubit();
      },
      seed: () => CartState(
        accountId: 'acc-1',
        models: [_item(quantity: 2)],
        status: CartRequestStatus.success,
      ),
      act: (cubit) async {
        cubit.incrementItem('cart-item-1');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.success)
            .having((s) => s.models.first.quantity, 'quantity', 3),
      ],
      verify: (_) {
        verify(
          () => updateUseCase.call(cartItemId: 'cart-item-1', quantity: 3),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'decrementItem floors quantity at 1',
      build: () {
        when(
          () => updateUseCase.call(
            cartItemId: any(named: 'cartItemId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => [_item(quantity: 1)]);
        return buildCubit();
      },
      seed: () => CartState(
        accountId: 'acc-1',
        models: [_item(quantity: 1)],
        status: CartRequestStatus.success,
      ),
      act: (cubit) async {
        cubit.decrementItem('cart-item-1');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.success)
            .having((s) => s.models.first.quantity, 'quantity', 1),
      ],
      verify: (_) {
        verify(
          () => updateUseCase.call(cartItemId: 'cart-item-1', quantity: 1),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'removeItem emits success with remaining items',
      build: () {
        when(
          () => removeUseCase.call(cartItemId: any(named: 'cartItemId')),
        ).thenAnswer((_) async => const []);
        return buildCubit();
      },
      seed: () => CartState(
        accountId: 'acc-1',
        models: [_item(quantity: 1)],
        status: CartRequestStatus.success,
      ),
      act: (cubit) async {
        cubit.removeItem('cart-item-1');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.success)
            .having((s) => s.models, 'models', isEmpty),
      ],
      verify: (_) {
        verify(() => removeUseCase.call(cartItemId: 'cart-item-1')).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'removeItem emits error when use case fails',
      build: () {
        when(
          () => removeUseCase.call(cartItemId: any(named: 'cartItemId')),
        ).thenThrow(Exception('remove failed'));
        return buildCubit();
      },
      seed: () => CartState(
        accountId: 'acc-1',
        models: [_item(quantity: 1)],
        status: CartRequestStatus.success,
      ),
      act: (cubit) async {
        cubit.removeItem('cart-item-1');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartRequestStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('remove failed'),
            ),
      ],
    );
  });
}
