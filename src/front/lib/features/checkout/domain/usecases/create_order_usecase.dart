import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/checkout/domain/entities/checkout_order_entity.dart';
import 'package:frontend/features/checkout/domain/repositories/checkout_repository.dart';

class CreateOrderUseCase {
  CreateOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<CheckoutOrderEntity> call({
    required String accountId,
    required String paymentMethod,
    required double amount,
    required List<CartItemEntity> items,
  }) {
    return _repository.createOrder(
      accountId: accountId,
      paymentMethod: paymentMethod,
      amount: amount,
      items: items,
    );
  }
}
