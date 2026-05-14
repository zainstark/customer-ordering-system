import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/orders/data/models/order_item_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderItemModel>> getOrders(String accountId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<OrderItemModel>> getOrders(String accountId) async {
    final path = ApiEndpoints.accountOrders.replaceFirst(
      '{accountId}',
      accountId,
    );
    final response = await _dioClient.get(path);
    final list = _extractList(response.data);
    return list
        .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
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
