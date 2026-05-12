
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.accountId,
    required super.orderId,
    required super.status,
    required super.placedAt,
    required super.totalAmount,
    required super.progress,
  });
 
}
