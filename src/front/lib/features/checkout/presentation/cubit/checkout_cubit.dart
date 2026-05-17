import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/checkout/domain/usecases/create_order_usecase.dart';
import 'package:frontend/features/checkout/domain/usecases/create_payment_session_usecase.dart';
import 'package:frontend/features/checkout/domain/usecases/get_payment_status_usecase.dart';
import 'package:frontend/features/checkout/domain/usecases/retry_payment_usecase.dart';
import 'package:frontend/features/checkout/domain/usecases/validate_cart_usecase.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._validateCartUseCase,
    this._createOrderUseCase,
    this._createPaymentSessionUseCase,
    this._getPaymentStatusUseCase,
    this._retryPaymentUseCase,
  ) : super(const CheckoutState(accountId: _defaultAccountId));

  static const String _defaultAccountId = 'test_account_001';

  final ValidateCartUseCase _validateCartUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  final CreatePaymentSessionUseCase _createPaymentSessionUseCase;
  final GetPaymentStatusUseCase _getPaymentStatusUseCase;
  final RetryPaymentUseCase _retryPaymentUseCase;

  Future<void> loadCheckout({String? accountId}) async {
    final currentAccountId = accountId ?? state.accountId;
    emit(state.copyWith(
      accountId: currentAccountId,
      status: CheckoutRequestStatus.validatingCart,
      clearErrorMessage: true,
    ));

    try {
      final items = await _validateCartUseCase(accountId: currentAccountId);
      emit(state.copyWith(
        items: items,
        status: CheckoutRequestStatus.readyToPay,
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CheckoutRequestStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void selectPaymentMethod(PaymentMethodType method) {
    emit(state.copyWith(selectedMethod: method, clearErrorMessage: true));
  }

  Future<void> placeOrder() async {
    if (state.status != CheckoutRequestStatus.readyToPay || !state.hasItems) {
      return;
    }

    emit(state.copyWith(
      status: CheckoutRequestStatus.creatingOrder,
      clearErrorMessage: true,
    ));

    try {
      final order = await _createOrderUseCase(
        accountId: state.accountId,
        paymentMethod: state.selectedMethod.label,
        amount: state.total,
        items: state.items,
      );

      emit(state.copyWith(
        status: CheckoutRequestStatus.creatingPaymentIntent,
        orderId: order.orderId,
        orderReference: order.reference,
      ));

      final session = await _createPaymentSessionUseCase(
        orderId: order.orderId,
        paymentMethod: state.selectedMethod.label,
        amount: order.amount,
      );

      emit(state.copyWith(
        status: CheckoutRequestStatus.awaitingPayment,
        paymentId: session.paymentId,
        paymentMessage: 'Payment session created. Waiting for confirmation.',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CheckoutRequestStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> refreshPaymentStatus() async {
    if (state.paymentId == null) return;

    emit(state.copyWith(
      status: CheckoutRequestStatus.processing,
      clearErrorMessage: true,
    ));

    try {
      final status = await _getPaymentStatusUseCase(paymentId: state.paymentId!);

      if (status.status == 'success') {
        emit(state.copyWith(
          status: CheckoutRequestStatus.success,
          paymentMessage: status.message,
        ));
      } else if (status.status == 'failed') {
        emit(state.copyWith(
          status: CheckoutRequestStatus.failure,
          paymentMessage: status.message,
          errorMessage: status.message,
        ));
      } else {
        emit(state.copyWith(
          status: CheckoutRequestStatus.awaitingPayment,
          paymentMessage: status.message,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: CheckoutRequestStatus.timeout,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> retryPayment() async {
    if (state.paymentId == null) return;

    emit(state.copyWith(
      status: CheckoutRequestStatus.processing,
      clearErrorMessage: true,
    ));

    try {
      final status = await _retryPaymentUseCase(paymentId: state.paymentId!);
      emit(state.copyWith(
        status: CheckoutRequestStatus.awaitingPayment,
        paymentMessage: status.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CheckoutRequestStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void reset() {
    emit(const CheckoutState(accountId: _defaultAccountId));
  }
}
