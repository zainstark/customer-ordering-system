import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase {
  const UpdateCartItemQuantityUseCase(this._cartRepository);

  final CartRepository _cartRepository;

  Future<List<CartItemEntity>> call({
    required String cartItemId,
    required int quantity,
  }) {
    return _cartRepository.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }
}
