import 'package:frontend/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:frontend/features/orders/domain/repositories/orders_repository.dart';

class GetOrderTrackingUseCase {
  const GetOrderTrackingUseCase(this._ordersRepository);

  final OrdersRepository _ordersRepository;

  Future<OrderTrackingEntity> call(String orderId) {
    return _ordersRepository.getOrderTracking(orderId);
  }
}
