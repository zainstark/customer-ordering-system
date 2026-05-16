import 'package:frontend/features/checkout/domain/entities/payment_status_entity.dart';
import 'package:frontend/features/checkout/domain/repositories/checkout_repository.dart';

class RetryPaymentUseCase {
  RetryPaymentUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<PaymentStatusEntity> call({required String paymentId}) {
    return _repository.retryPayment(paymentId: paymentId);
  }
}
