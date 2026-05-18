import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/entities/order_line_item_entity.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';
import 'package:frontend/features/orders/presentation/screens/order_tracking_screen.dart';
import 'package:frontend/features/orders/presentation/screens/orders_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersCubit extends MockCubit<OrdersState> implements OrdersCubit {}

class _FakeOrdersState extends Fake implements OrdersState {}

OrderItemEntity _order({
  required String id,
  required String orderId,
  required String status,
}) {
  return OrderItemEntity(
    id: id,
    accountId: 'acc-1',
    orderId: orderId,
    status: status,
    placedAt: DateTime(2025, 1, 2, 8, 30),
    totalAmount: 39.5,
    progress: 0.6,
    items: const [
      OrderLineItemEntity(
        id: 'line-1',
        title: 'Margherita',
        unitPrice: 19.75,
        quantity: 2,
        lineTotal: 39.5,
      ),
    ],
  );
}

Widget _buildOrdersApp(OrdersCubit cubit) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(900, 1200)),
      child: Scaffold(
        body: BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: const OrdersScreen(),
        ),
      ),
    ),
  );
}

Widget _buildTrackingApp(OrdersCubit cubit, {required String orderId}) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<OrdersCubit>.value(
        value: cubit,
        child: OrderTrackingScreen(orderId: orderId),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOrdersState());
    registerFallbackValue(OrdersTab.active);
  });

  group('OrdersScreen', () {
    late _MockOrdersCubit cubit;

    setUp(() {
      cubit = _MockOrdersCubit();
      whenListen(cubit, const Stream<OrdersState>.empty());
    });

    testWidgets('shows loading indicator while loading orders', (tester) async {
      when(
        () => cubit.state,
      ).thenReturn(const OrdersState(fetchStatus: FetchStatus.loading));

      await tester.pumpWidget(_buildOrdersApp(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state and retries load', (tester) async {
      when(() => cubit.state).thenReturn(
        const OrdersState(
          fetchStatus: FetchStatus.error,
          errorMessage: 'Orders are temporarily unavailable',
        ),
      );
      when(() => cubit.loadOrders()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildOrdersApp(cubit));

      expect(find.text('Orders are temporarily unavailable'), findsOneWidget);
      final retryButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      retryButton.onPressed?.call();
      await tester.pump();

      verify(() => cubit.loadOrders()).called(1);
    });

    testWidgets('shows empty state when fetch succeeds with no orders', (
      tester,
    ) async {
      when(
        () => cubit.state,
      ).thenReturn(const OrdersState(fetchStatus: FetchStatus.success));

      await tester.pumpWidget(_buildOrdersApp(cubit));

      expect(find.text('No orders available right now.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders success content and order card details', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(
        OrdersState(
          fetchStatus: FetchStatus.success,
          selectedTab: OrdersTab.active,
          activeOrders: [
            _order(id: '1', orderId: 'order-active-001', status: 'Pending'),
          ],
          pastOrders: [
            _order(id: '2', orderId: 'order-past-001', status: 'Delivered'),
          ],
        ),
      );

      await tester.pumpWidget(_buildOrdersApp(cubit));

      expect(find.text('Orders history'), findsOneWidget);
      expect(find.text('Order #ORDER-AC'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Quick summary'), findsOneWidget);
      expect(find.text('Track Order'), findsOneWidget);
    });

    testWidgets('switching tabs calls changeTab on cubit', (tester) async {
      when(() => cubit.state).thenReturn(
        OrdersState(
          fetchStatus: FetchStatus.success,
          selectedTab: OrdersTab.active,
          activeOrders: [
            _order(id: '1', orderId: 'order-active-001', status: 'Pending'),
          ],
          pastOrders: [
            _order(id: '2', orderId: 'order-past-001', status: 'Delivered'),
          ],
        ),
      );
      when(() => cubit.changeTab(any())).thenReturn(null);

      await tester.pumpWidget(_buildOrdersApp(cubit));
      final segmentedButton = tester.widget<SegmentedButton<OrdersTab>>(
        find.byType(SegmentedButton<OrdersTab>),
      );
      segmentedButton.onSelectionChanged?.call({OrdersTab.past});
      await tester.pump();

      verify(() => cubit.changeTab(OrdersTab.past)).called(1);
    });
  });

  group('OrderTrackingScreen', () {
    late _MockOrdersCubit cubit;

    setUp(() {
      cubit = _MockOrdersCubit();
      whenListen(cubit, const Stream<OrdersState>.empty());
    });

    testWidgets('shows "order not found" when order id is missing', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(
        const OrdersState(
          fetchStatus: FetchStatus.success,
          activeOrders: [],
          pastOrders: [],
        ),
      );

      await tester.pumpWidget(_buildTrackingApp(cubit, orderId: 'unknown-id'));

      expect(find.text('Track Order'), findsOneWidget);
      expect(find.text('Order not found'), findsOneWidget);
    });
  });
}
