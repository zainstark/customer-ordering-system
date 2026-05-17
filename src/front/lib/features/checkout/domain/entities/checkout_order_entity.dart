class CheckoutOrderEntity {
  const CheckoutOrderEntity({
    required this.orderId,
    required this.reference,
    required this.amount,
  });

  final String orderId;
  final String reference;
  final double amount;
}
