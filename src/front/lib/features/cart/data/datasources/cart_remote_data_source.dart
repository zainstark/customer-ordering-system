import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems({required String accountId});

  Future<List<CartItemModel>> addItem({
    required String accountId,
    required String menuItemId,
    required int quantity,
  });

  Future<List<CartItemModel>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<List<CartItemModel>> removeItem({required String cartItemId});

  Future<Map<String, dynamic>> validateCart();

  Future<List<CartItemModel>> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<CartItemModel>> getCartItems({required String accountId}) async {
    final response = await _dioClient.get(ApiEndpoints.cart);
    return _mapCartItems(response.data);
  }

  @override
  Future<List<CartItemModel>> addItem({
    required String accountId,
    required String menuItemId,
    required int quantity,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.cartItems,
      data: {'menu_item_id': menuItemId, 'quantity': quantity},
    );
    return _mapCartItems(response.data);
  }

  @override
  Future<List<CartItemModel>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final path = ApiEndpoints.cartItemById.replaceFirst(
      '{cartItemId}',
      cartItemId,
    );
    final response = await _dioClient.patch(path, data: {'quantity': quantity});
    return _mapCartItems(response.data);
  }

  @override
  Future<List<CartItemModel>> removeItem({required String cartItemId}) async {
    final path =
        '${ApiEndpoints.cartItemById.replaceFirst('{cartItemId}', cartItemId)}delete/';
    final response = await _dioClient.delete(path);
    return _mapCartItems(response.data);
  }

  @override
  Future<Map<String, dynamic>> validateCart() async {
    final response = await _dioClient.post(ApiEndpoints.validateCart);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const AppException(
        message: 'Invalid cart validation response format.',
      );
    }
    return data;
  }

  @override
  Future<List<CartItemModel>> clearCart() async {
    final response = await _dioClient.delete(ApiEndpoints.clearCart);
    return _mapCartItems(response.data);
  }

  List<CartItemModel> _mapCartItems(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const AppException(message: 'Invalid cart response format.');
    }

    final items = data['items'];
    if (items is! List) {
      throw const AppException(message: 'Invalid cart response format.');
    }

    return items
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
