import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';

enum OrdersRequestStatus { initial, loading, success, error }

class OrdersState {
  const OrdersState({
    required this.selectedTab,
    required this.activeOrders,
    required this.pastOrders,
    this.status = OrdersRequestStatus.initial,
    this.errorMessage,
  });

  final OrdersTab selectedTab;
  final List<OrderItemEntity> activeOrders;
  final List<OrderItemEntity> pastOrders;
  final OrdersRequestStatus status;
  final String? errorMessage;

  List<OrderItemEntity> get visibleOrders =>
      selectedTab == OrdersTab.active ? activeOrders : pastOrders;

  OrdersState copyWith({
    OrdersTab? selectedTab,
    List<OrderItemEntity>? activeOrders,
    List<OrderItemEntity>? pastOrders,
    OrdersRequestStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return OrdersState(
      selectedTab: selectedTab ?? this.selectedTab,
      activeOrders: activeOrders ?? this.activeOrders,
      pastOrders: pastOrders ?? this.pastOrders,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
