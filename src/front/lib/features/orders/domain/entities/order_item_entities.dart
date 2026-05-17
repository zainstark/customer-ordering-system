import 'package:frontend/features/orders/domain/entities/order_line_item_entity.dart';

class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.accountId,
    required this.orderId,
    required this.status,
    required this.placedAt,
    required this.totalAmount,
    required this.progress,
    required this.items,
  });

  final String id;
  final String accountId;
  final String orderId;
  final String status;
  final DateTime placedAt;
  final double totalAmount;
  final double progress;
  final List<OrderLineItemEntity> items;
}
