import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required this._getOrdersUseCase})
    : super(
        const OrdersState(
          selectedTab: OrdersTab.active,
          activeOrders: [],
          pastOrders: [],
        ),
      );

  static const String _defaultAccountId = 'ACC-100';

  final GetOrdersUseCase _getOrdersUseCase;

  Future<void> loadOrders({String? accountId}) async {
    emit(
      state.copyWith(
        status: OrdersRequestStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final orders = await _getOrdersUseCase(
        accountId: accountId ?? _defaultAccountId,
      );
      final activeOrders = <OrderItemEntity>[];
      final pastOrders = <OrderItemEntity>[];

      for (final order in orders) {
        if (_isPastOrder(order.status)) {
          pastOrders.add(order);
        } else {
          activeOrders.add(order);
        }
      }

      emit(
        state.copyWith(
          activeOrders: activeOrders,
          pastOrders: pastOrders,
          status: OrdersRequestStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: OrdersRequestStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void changeTab(OrdersTab tab) {
    if (state.selectedTab == tab) return;
    emit(state.copyWith(selectedTab: tab));
  }

  bool _isPastOrder(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'delivered' ||
        normalized == 'cancelled' ||
        normalized == 'failed';
  }
}

enum OrdersTab { active, past }
