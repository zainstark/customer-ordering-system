import 'package:frontend/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._cartRemoteDataSource);

  final CartRemoteDataSource _cartRemoteDataSource;

  @override
  Future<List<CartItemEntity>> getCartItems({required String accountId}) {
    return _cartRemoteDataSource.getCartItems(accountId: accountId);
  }

  @override
  Future<List<CartItemEntity>> addItem({
    required String accountId,
    required String menuItemId,
    required int quantity,
  }) {
    return _cartRemoteDataSource.addItem(
      accountId: accountId,
      menuItemId: menuItemId,
      quantity: quantity,
    );
  }

  @override
  Future<List<CartItemEntity>> removeItem({
    required String cartItemId,
  }) {
    return _cartRemoteDataSource.removeItem(cartItemId: cartItemId);
  }

  @override
  Future<List<CartItemEntity>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) {
    return _cartRemoteDataSource.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }
}
