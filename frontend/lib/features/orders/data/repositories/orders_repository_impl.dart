import 'package:frontend/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._ordersRemoteDataSource);

  final OrdersRemoteDataSource _ordersRemoteDataSource;

  @override
  Future<List<OrderItemEntity>> getOrders({required String accountId}) {
    return _ordersRemoteDataSource.getOrders(accountId);
  }
}
