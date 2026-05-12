
import 'package:frontend/features/orders/data/models/order_item_model.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';

class OrdersState {
  const OrdersState({
    required this.selectedTab,
    required this.activeOrders,
    required this.pastOrders,
  });

  final OrdersTab selectedTab;
  final List<OrderItemModel> activeOrders;
  final List<OrderItemModel> pastOrders;

  List<OrderItemModel> get visibleOrders =>
      selectedTab == OrdersTab.active ? activeOrders : pastOrders;

  OrdersState copyWith({
    OrdersTab? selectedTab,
    List<OrderItemModel>? activeOrders,
    List<OrderItemModel>? pastOrders,
  }) {
    return OrdersState(
      selectedTab: selectedTab ?? this.selectedTab,
      activeOrders: activeOrders ?? this.activeOrders,
      pastOrders: pastOrders ?? this.pastOrders,
    );
  }
}
