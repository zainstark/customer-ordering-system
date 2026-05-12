
class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.accountId,
    required this.orderId,
    required this.status,
    required this.placedAt,
    required this.totalAmount,
    required this.progress,
  });

  final String id;
  final String accountId;
  final String orderId;
  final String status;
  final DateTime placedAt;
  final double totalAmount;
  final double progress;
}
