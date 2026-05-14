import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems(String cartId);

  Future<List<CartItemModel>> updateItemQuantity({
    required String cartId,
    required String cartItemId,
    required int quantity,
  });

  Future<List<CartItemModel>> removeItem({
    required String cartId,
    required String cartItemId,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<CartItemModel>> getCartItems(String cartId) async {
    final path = ApiEndpoints.cartById.replaceFirst('{cartId}', cartId);
    final response = await _dioClient.get(path);
    final list = _extractItems(response.data);
    return list
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CartItemModel>> updateItemQuantity({
    required String cartId,
    required String cartItemId,
    required int quantity,
  }) async {
    final path = ApiEndpoints.cartItemById
        .replaceFirst('{cartId}', cartId)
        .replaceFirst('{cartItemId}', cartItemId);
    final response = await _dioClient.put(path, data: {'quantity': quantity});
    final list = _extractItems(response.data);
    return list
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CartItemModel>> removeItem({
    required String cartId,
    required String cartItemId,
  }) async {
    final path = ApiEndpoints.cartItemById
        .replaceFirst('{cartId}', cartId)
        .replaceFirst('{cartItemId}', cartItemId);
    final response = await _dioClient.delete(path);
    final list = _extractItems(response.data);
    return list
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final directItems = data['items'];
      if (directItems is List) return directItems;

      final cartItems = data['cartItems'];
      if (cartItems is List) return cartItems;

      final result = data['data'];
      if (result is List) return result;
      if (result is Map<String, dynamic>) {
        final nestedItems = result['items'];
        if (nestedItems is List) return nestedItems;
      }
    }
    throw const AppException(message: 'Invalid cart response format.');
  }
}
