import 'package:frontend/features/cart/data/models/cart_item_model.dart';

class CartState {
  const CartState({required this.cartId, required this.models});

  final String cartId;
  final List<CartItemModel> models;

  double get subtotal => models.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => 2.99;
  double get taxes => subtotal * 0.09;
  double get total => subtotal + deliveryFee + taxes;

  CartState copyWith({String? cartId, List<CartItemModel>? models}) {
    return CartState(
      cartId: cartId ?? this.cartId,
      models: models ?? this.models,
    );
  }
}
