class PaymentStatusEntity {
  const PaymentStatusEntity({
    required this.paymentId,
    required this.status,
    required this.message,
  });

  final String paymentId;
  final String status;
  final String? message;
}
