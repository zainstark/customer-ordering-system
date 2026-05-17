import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';

enum OrdersTab { active, past }
enum FetchStatus { initial, loading, success, error }
enum PlaceOrderStatus { initial, loading, success, error }

class OrdersState {
  const OrdersState({
    this.selectedTab = OrdersTab.active,
    this.activeOrders = const [],
    this.pastOrders = const [],
    this.fetchStatus = FetchStatus.initial,
    this.placeOrderStatus = PlaceOrderStatus.initial,
    this.placedOrder,
    this.errorMessage,
    this.placeOrderError,
  });

  final OrdersTab selectedTab;
  final List<OrderItemEntity> activeOrders;
  final List<OrderItemEntity> pastOrders;
  final FetchStatus fetchStatus;
  final PlaceOrderStatus placeOrderStatus;
  final OrderItemEntity? placedOrder;
  final String? errorMessage;      // fetch errors
  final String? placeOrderError;   // place-order errors

  List<OrderItemEntity> get visibleOrders =>
      selectedTab == OrdersTab.active ? activeOrders : pastOrders;

  OrdersState copyWith({
    OrdersTab? selectedTab,
    List<OrderItemEntity>? activeOrders,
    List<OrderItemEntity>? pastOrders,
    FetchStatus? fetchStatus,
    PlaceOrderStatus? placeOrderStatus,
    OrderItemEntity? placedOrder,
    String? errorMessage,
    String? placeOrderError,
    bool clearErrorMessage = false,
    bool clearPlaceOrderError = false,
    bool clearPlacedOrder = false,
  }) {
    return OrdersState(
      selectedTab: selectedTab ?? this.selectedTab,
      activeOrders: activeOrders ?? this.activeOrders,
      pastOrders: pastOrders ?? this.pastOrders,
      fetchStatus: fetchStatus ?? this.fetchStatus,
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      placedOrder: clearPlacedOrder ? null : placedOrder ?? this.placedOrder,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      placeOrderError: clearPlaceOrderError ? null : placeOrderError ?? this.placeOrderError,
    );
  }
}