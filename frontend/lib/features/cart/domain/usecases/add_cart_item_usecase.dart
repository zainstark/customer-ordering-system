import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';

class AddCartItemUseCase {
  const AddCartItemUseCase(this._cartRepository);

  final CartRepository _cartRepository;

  Future<List<CartItemEntity>> call({
    required String accountId,
    required String menuItemId,
    required int quantity,
  }) {
    return _cartRepository.addItem(
      accountId: accountId,
      menuItemId: menuItemId,
      quantity: quantity,
    );
  }
}
