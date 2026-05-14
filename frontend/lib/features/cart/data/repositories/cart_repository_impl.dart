import 'package:frontend/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._cartRemoteDataSource);

  final CartRemoteDataSource _cartRemoteDataSource;

  @override
  Future<List<CartItemEntity>> getCartItems({required String cartId}) {
    return _cartRemoteDataSource.getCartItems(cartId);
  }

  @override
  Future<List<CartItemEntity>> removeItem({
    required String cartId,
    required String cartItemId,
  }) {
    return _cartRemoteDataSource.removeItem(
      cartId: cartId,
      cartItemId: cartItemId,
    );
  }

  @override
  Future<List<CartItemEntity>> updateItemQuantity({
    required String cartId,
    required String cartItemId,
    required int quantity,
  }) {
    return _cartRemoteDataSource.updateItemQuantity(
      cartId: cartId,
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }
}
