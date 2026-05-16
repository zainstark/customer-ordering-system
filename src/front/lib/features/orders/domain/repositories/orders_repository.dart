import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';

abstract class OrdersRepository {
  Future<List<OrderItemEntity>> getOrders({required String accountId});
}
