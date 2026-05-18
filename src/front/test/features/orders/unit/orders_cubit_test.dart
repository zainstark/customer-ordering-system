import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/entities/order_line_item_entity.dart';
import 'package:frontend/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:frontend/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

class _MockPlaceOrderUseCase extends Mock implements PlaceOrderUseCase {}

OrderItemEntity _order({
  required String id,
  required String orderId,
  required String status,
  double totalAmount = 24.0,
}) {
  return OrderItemEntity(
    id: id,
    accountId: 'account-1',
    orderId: orderId,
    status: status,
    placedAt: DateTime(2025, 1, 1, 12, 0),
    totalAmount: totalAmount,
    progress: 0.5,
    items: const [
      OrderLineItemEntity(
        id: 'line-1',
        title: 'Pizza',
        unitPrice: 12,
        quantity: 2,
        lineTotal: 24,
      ),
    ],
  );
}

void main() {
  group('OrdersState', () {
    test('visibleOrders follows selected tab', () {
      final active = _order(id: '1', orderId: 'A-1', status: 'PENDING');
      final past = _order(id: '2', orderId: 'A-2', status: 'Delivered');

      final activeState = OrdersState(
        activeOrders: [active],
        pastOrders: [past],
      );
      final pastState = activeState.copyWith(selectedTab: OrdersTab.past);

      expect(activeState.visibleOrders, [active]);
      expect(pastState.visibleOrders, [past]);
    });

    test('copyWith clear flags clear errors and placed order', () {
      final original = OrdersState(
        placeOrderStatus: PlaceOrderStatus.error,
        placedOrder: _order(id: '3', orderId: 'A-3', status: 'FAILED'),
        errorMessage: 'fetch failed',
        placeOrderError: 'place failed',
      );

      final updated = original.copyWith(
        clearErrorMessage: true,
        clearPlaceOrderError: true,
        clearPlacedOrder: true,
      );

      expect(updated.errorMessage, isNull);
      expect(updated.placeOrderError, isNull);
      expect(updated.placedOrder, isNull);
    });
  });

  group('OrdersCubit', () {
    late _MockGetOrdersUseCase getOrdersUseCase;
    late _MockPlaceOrderUseCase placeOrderUseCase;

    setUp(() {
      getOrdersUseCase = _MockGetOrdersUseCase();
      placeOrderUseCase = _MockPlaceOrderUseCase();
    });

    OrdersCubit buildCubit() =>
        OrdersCubit(getOrdersUseCase, placeOrderUseCase);

    blocTest<OrdersCubit, OrdersState>(
      'loadOrders emits loading then success and splits active/past by status',
      build: () {
        when(() => getOrdersUseCase()).thenAnswer(
          (_) async => [
            _order(id: '1', orderId: 'AA-1', status: 'Pending'),
            _order(id: '2', orderId: 'AA-2', status: ' delivered '),
            _order(id: '3', orderId: 'AA-3', status: 'FAILED'),
            _order(id: '4', orderId: 'AA-4', status: 'cancelled'),
          ],
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        isA<OrdersState>()
            .having((s) => s.fetchStatus, 'fetchStatus', FetchStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<OrdersState>()
            .having((s) => s.fetchStatus, 'fetchStatus', FetchStatus.success)
            .having((s) => s.activeOrders.length, 'activeOrders.length', 1)
            .having((s) => s.pastOrders.length, 'pastOrders.length', 3),
      ],
      verify: (_) {
        verify(() => getOrdersUseCase()).called(1);
      },
    );

    blocTest<OrdersCubit, OrdersState>(
      'loadOrders emits loading then error when fetch fails',
      build: () {
        when(
          () => getOrdersUseCase(),
        ).thenThrow(Exception('orders unavailable'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        isA<OrdersState>().having(
          (s) => s.fetchStatus,
          'fetchStatus',
          FetchStatus.loading,
        ),
        isA<OrdersState>()
            .having((s) => s.fetchStatus, 'fetchStatus', FetchStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('orders unavailable'),
            ),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'placeOrder emits loading then success and normalizes status to PENDING',
      build: () {
        when(
          () => placeOrderUseCase.call(address: any(named: 'address')),
        ).thenAnswer(
          (_) async => _order(
            id: '7',
            orderId: 'PLACED-1',
            status: 'DELIVERED',
            totalAmount: 48,
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.placeOrder(address: '123 Main St'),
      expect: () => [
        isA<OrdersState>()
            .having(
              (s) => s.placeOrderStatus,
              'placeOrderStatus',
              PlaceOrderStatus.loading,
            )
            .having((s) => s.placeOrderError, 'placeOrderError', isNull),
        isA<OrdersState>()
            .having(
              (s) => s.placeOrderStatus,
              'placeOrderStatus',
              PlaceOrderStatus.success,
            )
            .having(
              (s) => s.placedOrder?.status,
              'placedOrder.status',
              'PENDING',
            ),
      ],
      verify: (_) {
        verify(() => placeOrderUseCase.call(address: '123 Main St')).called(1);
      },
    );

    blocTest<OrdersCubit, OrdersState>(
      'placeOrder exposes loading first for duplicate-submit guard behavior',
      build: () {
        when(
          () => placeOrderUseCase.call(address: any(named: 'address')),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _order(id: '8', orderId: 'PLACED-2', status: 'PENDING');
        });
        return buildCubit();
      },
      act: (cubit) async {
        final inFlight = cubit.placeOrder(address: '456 Main St');
        expect(cubit.state.placeOrderStatus, PlaceOrderStatus.loading);
        await inFlight;
      },
      expect: () => [
        isA<OrdersState>().having(
          (s) => s.placeOrderStatus,
          'placeOrderStatus',
          PlaceOrderStatus.loading,
        ),
        isA<OrdersState>().having(
          (s) => s.placeOrderStatus,
          'placeOrderStatus',
          PlaceOrderStatus.success,
        ),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'placeOrder emits loading then error when placement fails',
      build: () {
        when(
          () => placeOrderUseCase.call(address: any(named: 'address')),
        ).thenThrow(
          Exception('We were unable to create your order. Please try again.'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.placeOrder(address: '123 Main St'),
      expect: () => [
        isA<OrdersState>().having(
          (s) => s.placeOrderStatus,
          'placeOrderStatus',
          PlaceOrderStatus.loading,
        ),
        isA<OrdersState>()
            .having(
              (s) => s.placeOrderStatus,
              'placeOrderStatus',
              PlaceOrderStatus.error,
            )
            .having(
              (s) => s.placeOrderError,
              'placeOrderError',
              contains('unable to create your order'),
            ),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'resetPlaceOrder clears placed order and placement error',
      seed: () => OrdersState(
        placeOrderStatus: PlaceOrderStatus.error,
        placedOrder: _order(id: '9', orderId: 'PLACED-9', status: 'FAILED'),
        placeOrderError: 'failed',
      ),
      build: buildCubit,
      act: (cubit) => cubit.resetPlaceOrder(),
      expect: () => [
        isA<OrdersState>()
            .having(
              (s) => s.placeOrderStatus,
              'placeOrderStatus',
              PlaceOrderStatus.initial,
            )
            .having((s) => s.placedOrder, 'placedOrder', isNull)
            .having((s) => s.placeOrderError, 'placeOrderError', isNull),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'changeTab emits only when tab changes',
      seed: () => const OrdersState(selectedTab: OrdersTab.active),
      build: buildCubit,
      act: (cubit) => cubit.changeTab(OrdersTab.past),
      expect: () => [
        isA<OrdersState>().having(
          (s) => s.selectedTab,
          'selectedTab',
          OrdersTab.past,
        ),
      ],
    );

    blocTest<OrdersCubit, OrdersState>(
      'changeTab does not emit when selecting current tab',
      seed: () => const OrdersState(selectedTab: OrdersTab.active),
      build: buildCubit,
      act: (cubit) => cubit.changeTab(OrdersTab.active),
      expect: () => <OrdersState>[],
    );
  });
}
