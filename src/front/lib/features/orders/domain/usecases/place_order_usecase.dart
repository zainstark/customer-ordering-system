import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/repositories/orders_repository.dart';

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._ordersRepository);

  final OrdersRepository _ordersRepository;

  Future<OrderItemEntity> call({required String address}) {
    return _ordersRepository.placeOrder(address: address);
  }
}
