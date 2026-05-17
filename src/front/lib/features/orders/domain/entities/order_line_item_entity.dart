class OrderLineItemEntity {
  const OrderLineItemEntity({
    required this.id,
    required this.title,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final String id;
  final String title;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
}
