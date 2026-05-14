import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';

class GetCartItemsUseCase {
  const GetCartItemsUseCase(this._cartRepository);

  final CartRepository _cartRepository;

  Future<List<CartItemEntity>> call({required String cartId}) {
    return _cartRepository.getCartItems(cartId: cartId);
  }
}
