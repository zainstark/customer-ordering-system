import 'package:flutter/foundation.dart';
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

  Future<List<CartItemModel>> removeItem({
    required String cartItemId,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<CartItemModel>> getCartItems({required String accountId}) async {
    debugPrint('📦 CartRemoteDataSource.getCartItems called with accountId: $accountId');
    final response = await _dioClient.get(
      ApiEndpoints.cart,
      queryParameters: {'account_id': accountId},
    );
    debugPrint('📦 CartRemoteDataSource response received: ${response.data}');
    final list = _extractItems(response.data);
    return list
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CartItemModel>> addItem({
    required String accountId,
    required String menuItemId,
    required int quantity,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.cartItems,
      data: {
        'account_id': accountId,
        'menu_item_id': menuItemId,
        'quantity': quantity,
      },
    );
    final list = _extractItems(response.data);
    return list
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CartItemModel>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final path =
        ApiEndpoints.cartItemById.replaceFirst('{cartItemId}', cartItemId);
    final response = await _dioClient.patch(path, data: {'quantity': quantity});
    final list = _extractItems(response.data);
    return list
        .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CartItemModel>> removeItem({
    required String cartItemId,
  }) async {
    final path = '${ApiEndpoints.cartItemById.replaceFirst('{cartItemId}', cartItemId)}delete/';
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
