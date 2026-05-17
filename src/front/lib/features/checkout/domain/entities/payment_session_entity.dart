class PaymentSessionEntity {
  const PaymentSessionEntity({
    required this.paymentId,
    required this.checkoutUrl,
    required this.status,
  });

  final String paymentId;
  final String checkoutUrl;
  final String status;
}
