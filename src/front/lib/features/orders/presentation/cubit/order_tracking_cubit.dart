import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/domain/usecases/get_order_tracking_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  OrderTrackingCubit(this._getOrderTrackingUseCase) : super(const OrderTrackingState());

  final GetOrderTrackingUseCase _getOrderTrackingUseCase;

  Future<void> loadTracking(String orderId) async {
    emit(state.copyWith(status: OrderTrackingStatus.loading));
    try {
      final tracking = await _getOrderTrackingUseCase(orderId);
      emit(state.copyWith(
        status: OrderTrackingStatus.success,
        tracking: tracking,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
