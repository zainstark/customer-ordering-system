import 'package:frontend/features/checkout/domain/entities/payment_session_entity.dart';
import 'package:frontend/features/checkout/domain/repositories/checkout_repository.dart';

class CreatePaymentSessionUseCase {
  CreatePaymentSessionUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<PaymentSessionEntity> call({
    required String orderId,
    required String paymentMethod,
    required double amount,
  }) {
    return _repository.createPaymentSession(
      orderId: orderId,
      paymentMethod: paymentMethod,
      amount: amount,
    );
  }
}
