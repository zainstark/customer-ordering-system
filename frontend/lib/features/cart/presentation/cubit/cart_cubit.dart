import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required this._getCartItemsUseCase,
    required this._updateCartItemQuantityUseCase,
    required this._removeCartItemUseCase,
  }) : super(const CartState(cartId: _defaultCartId, models: []));

  static const String _defaultCartId = 'CRT-1001';

  final GetCartItemsUseCase _getCartItemsUseCase;
  final UpdateCartItemQuantityUseCase _updateCartItemQuantityUseCase;
  final RemoveCartItemUseCase _removeCartItemUseCase;

  Future<void> loadCart({String? cartId}) async {
    final currentCartId = cartId ?? state.cartId;
    emit(
      state.copyWith(
        cartId: currentCartId,
        status: CartRequestStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final items = await _getCartItemsUseCase(cartId: currentCartId);
      emit(
        state.copyWith(
          models: items,
          status: CartRequestStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CartRequestStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void incrementItem(String id) {
    _incrementItem(id);
  }

  Future<void> _incrementItem(String id) async {
    final item = _findItemById(id);
    if (item == null) return;

    try {
      final items = await _updateCartItemQuantityUseCase(
        cartId: state.cartId,
        cartItemId: id,
        quantity: item.quantity + 1,
      );
      emit(
        state.copyWith(
          models: items,
          status: CartRequestStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CartRequestStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void decrementItem(String id) {
    _decrementItem(id);
  }

  Future<void> _decrementItem(String id) async {
    final item = _findItemById(id);
    if (item == null) return;
    final nextQty = item.quantity > 1 ? item.quantity - 1 : 1;

    try {
      final items = await _updateCartItemQuantityUseCase(
        cartId: state.cartId,
        cartItemId: id,
        quantity: nextQty,
      );
      emit(
        state.copyWith(
          models: items,
          status: CartRequestStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CartRequestStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void removeItem(String id) {
    _removeItem(id);
  }

  Future<void> _removeItem(String id) async {
    try {
      final items = await _removeCartItemUseCase(
        cartId: state.cartId,
        cartItemId: id,
      );
      emit(
        state.copyWith(
          models: items,
          status: CartRequestStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CartRequestStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  CartItemEntity? _findItemById(String id) {
    for (final item in state.models) {
      if (item.id == id) return item;
    }
    return null;
  }
}
