import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/domain/usecases/place_order_usecase.dart';

enum OrderRequestStatus { initial, loading, success, error }

class OrderState {
  const OrderState({
    this.status = OrderRequestStatus.initial,
    this.order,
    this.errorMessage,
  });

  final OrderRequestStatus status;
  final OrderItemEntity? order;
  final String? errorMessage;

  OrderState copyWith({
    OrderRequestStatus? status,
    OrderItemEntity? order,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class OrderCubit extends Cubit<OrderState> {
  OrderCubit(this._placeOrderUseCase) : super(const OrderState());

  final PlaceOrderUseCase _placeOrderUseCase;

  Future<void> placeOrder({required String address}) async {
    emit(state.copyWith(status: OrderRequestStatus.loading, clearErrorMessage: true));
    try {
      final order = await _placeOrderUseCase.call(address: address);
      // Ensure order status is PENDING before payment (frontend signal). Backend
      // should already return PENDING, but normalize here to be safe.
      final pendingOrder = OrderItemEntity(
        id: order.id,
        accountId: order.accountId,
        orderId: order.orderId,
        status: 'PENDING',
        placedAt: order.placedAt,
        totalAmount: order.totalAmount,
        progress: order.progress,
        items: order.items,
      );

      emit(state.copyWith(status: OrderRequestStatus.success, order: pendingOrder));
    } catch (e) {
      emit(state.copyWith(status: OrderRequestStatus.error, errorMessage: e.toString()));
    }
  }
}
