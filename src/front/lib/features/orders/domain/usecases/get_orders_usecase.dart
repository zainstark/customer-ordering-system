import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/repositories/orders_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._ordersRepository);

  final OrdersRepository _ordersRepository;

  Future<List<OrderItemEntity>> call() {
    return _ordersRepository.getOrders();
  }
}
