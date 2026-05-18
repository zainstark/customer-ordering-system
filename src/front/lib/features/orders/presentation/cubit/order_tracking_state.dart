import 'package:equatable/equatable.dart';
import 'package:frontend/features/orders/domain/entities/order_tracking_entity.dart';

enum OrderTrackingStatus { initial, loading, success, error }

class OrderTrackingState extends Equatable {
  const OrderTrackingState({
    this.status = OrderTrackingStatus.initial,
    this.tracking,
    this.errorMessage,
  });

  final OrderTrackingStatus status;
  final OrderTrackingEntity? tracking;
  final String? errorMessage;

  OrderTrackingState copyWith({
    OrderTrackingStatus? status,
    OrderTrackingEntity? tracking,
    String? errorMessage,
  }) {
    return OrderTrackingState(
      status: status ?? this.status,
      tracking: tracking ?? this.tracking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tracking, errorMessage];
}
