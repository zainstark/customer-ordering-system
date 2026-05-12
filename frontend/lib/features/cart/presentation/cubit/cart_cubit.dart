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
                  'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
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
                  'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
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
