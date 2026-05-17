import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/checkout/domain/repositories/checkout_repository.dart';

class ValidateCartUseCase {
  ValidateCartUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<List<CartItemEntity>> call({required String accountId}) {
    return _repository.validateCart(accountId: accountId);
  }
}
