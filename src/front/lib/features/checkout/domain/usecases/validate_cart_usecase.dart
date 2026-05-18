import 'package:frontend/features/checkout/domain/repositories/checkout_repository.dart';

class ValidateCartUseCase {
  ValidateCartUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<bool> call({required String accountId}) {
    return _repository.validateCart(accountId: accountId);
  }
}
