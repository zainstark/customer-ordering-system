import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';

class RemoveCartItemUseCase {
  const RemoveCartItemUseCase(this._cartRepository);

  final CartRepository _cartRepository;

  Future<List<CartItemEntity>> call({
    required String cartItemId,
  }) {
    return _cartRepository.removeItem(cartItemId: cartItemId);
  }
}
