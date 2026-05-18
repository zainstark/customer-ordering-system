import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/entities/order_tracking_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderItemEntity>> getOrders();
  Future<OrderItemEntity> placeOrder({required String address});
  Future<OrderTrackingEntity> getOrderTracking(String orderId);
}
