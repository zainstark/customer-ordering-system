import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:frontend/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._getOrdersUseCase, this._placeOrderUseCase)
      : super(const OrdersState());

  final GetOrdersUseCase _getOrdersUseCase;
  final PlaceOrderUseCase _placeOrderUseCase;

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    emit(state.copyWith(
      fetchStatus: FetchStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final orders = await _getOrdersUseCase();
      final active = <OrderItemEntity>[];
      final past = <OrderItemEntity>[];

      for (final order in orders) {
        _isPastOrder(order.status) ? past.add(order) : active.add(order);
      }

      emit(state.copyWith(
        fetchStatus: FetchStatus.success,
        activeOrders: active,
        pastOrders: past,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchStatus: FetchStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── Place order ────────────────────────────────────────────────────────────

  Future<void> placeOrder({required String address}) async {
    emit(state.copyWith(
      placeOrderStatus: PlaceOrderStatus.loading,
      clearPlaceOrderError: true,
    ));

    try {
      final order = await _placeOrderUseCase.call(address: address);

      // Normalize to PENDING as a frontend safety measure
      final pendingOrder = OrderItemEntity(
        id: order.id,
        accountId: order.accountId,
        orderId: order.orderId,
        status: 'PENDING',
        placedAt: order.placedAt,
        totalAmount: order.totalAmount,
        progress: order.progress,
        items: order.items,
      );

      emit(state.copyWith(
        placeOrderStatus: PlaceOrderStatus.success,
        placedOrder: pendingOrder,
      ));
    } catch (e) {
      emit(state.copyWith(
        placeOrderStatus: PlaceOrderStatus.error,
        placeOrderError: e.toString(),
      ));
    }
  }

  void resetPlaceOrder() {
    emit(state.copyWith(
      placeOrderStatus: PlaceOrderStatus.initial,
      clearPlacedOrder: true,
      clearPlaceOrderError: true,
    ));
  }

  // ── Tab ────────────────────────────────────────────────────────────────────

  void changeTab(OrdersTab tab) {
    if (state.selectedTab == tab) return;
    emit(state.copyWith(selectedTab: tab));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isPastOrder(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'delivered' ||
        normalized == 'cancelled' ||
        normalized == 'failed';
  }
}