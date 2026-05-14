import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems({required String cartId});

  Future<List<CartItemEntity>> updateItemQuantity({
    required String cartId,
    required String cartItemId,
    required int quantity,
  });

  Future<List<CartItemEntity>> removeItem({
    required String cartId,
    required String cartItemId,
  });
}
