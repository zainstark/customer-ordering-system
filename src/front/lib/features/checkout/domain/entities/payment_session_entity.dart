class PaymentSessionEntity {
  const PaymentSessionEntity({
    required this.paymentId,
    required this.checkoutUrl,
    required this.status,
    this.clientSecret,
  });

  final String paymentId;
  final String checkoutUrl;
  final String status;
  final String? clientSecret;
}
