import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';

enum CartRequestStatus { initial, loading, success, error }

class CartState {
  const CartState({
    required this.cartId,
    required this.models,
    this.status = CartRequestStatus.initial,
    this.errorMessage,
  });

  final String cartId;
  final List<CartItemEntity> models;
  final CartRequestStatus status;
  final String? errorMessage;

  double get subtotal =>
      models.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  double get deliveryFee => 2.99;
  double get taxes => subtotal * 0.09;
  double get total => subtotal + deliveryFee + taxes;

  CartState copyWith({
    String? cartId,
    List<CartItemEntity>? models,
    CartRequestStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CartState(
      cartId: cartId ?? this.cartId,
      models: models ?? this.models,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
