import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems({required String accountId});

  Future<List<CartItemEntity>> addItem({
    required String accountId,
    required String menuItemId,
    required int quantity,
  });

  Future<List<CartItemEntity>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<List<CartItemEntity>> removeItem({
    required String cartItemId,
  });
}
