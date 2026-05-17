import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/orders/data/models/order_item_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderItemModel>> getOrders();
  Future<OrderItemModel> placeOrder({required String address});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<OrderItemModel>> getOrders() async {
    final response = await _dioClient.get(ApiEndpoints.orders);
    final list = _extractList(response.data);
    return list
        .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderItemModel> placeOrder({required String address}) async {
    final response = await _dioClient.post(
      ApiEndpoints.placeOrder,
      data: {'address': address},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return OrderItemModel.fromMap(data);
      }
      throw const AppException(message: 'Invalid order response format.');
    }

    throw AppException(message: 'Failed to place order: ${response.statusMessage}');
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final orders = data['orders'];
      if (orders is List) return orders;

      final result = data['data'];
      if (result is List) return result;
      if (result is Map<String, dynamic>) {
        final nestedOrders = result['orders'];
        if (nestedOrders is List) return nestedOrders;
      }
    }
    throw const AppException(message: 'Invalid orders response format.');
  }
}
