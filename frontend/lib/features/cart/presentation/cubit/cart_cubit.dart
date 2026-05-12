import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/cart/data/models/cart_item_model.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit()
    : super(
        CartState(
          cartId: 'CRT-1001',
          models: [
            CartItemModel(
              id: 'c1',
              cartId: 'CRT-1001',
              menuItemId: 'MI-100',
              title: 'The Signature Burger',
              subtitle: 'Double patty, cheddar, secret sauce',
              unitPrice: 14.5,
              quantity: 1,
              imageUrl:
                  'https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
            ),
            CartItemModel(
              id: 'c2',
              cartId: 'CRT-1001',
              menuItemId: 'MI-200',
              title: 'Classic Margherita',
              subtitle: 'Sourdough, basil, San Marzano tomato',
              unitPrice: 18.0,
              quantity: 2,
              imageUrl:
                  'https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
            ),
          ],
        ),
      );

  void incrementItem(String id) {
    emit(
      state.copyWith(
        models: state.models.map((item) {
          if (item.id != id) return item;
          return item.copyWith(quantity: item.quantity + 1);
        }).toList(),
      ),
    );
  }

  void decrementItem(String id) {
    emit(
      state.copyWith(
        models: state.models.map((item) {
          if (item.id != id) return item;
          final nextQty = item.quantity > 1 ? item.quantity - 1 : 1;
          return item.copyWith(quantity: nextQty);
        }).toList(),
      ),
    );
  }
}
