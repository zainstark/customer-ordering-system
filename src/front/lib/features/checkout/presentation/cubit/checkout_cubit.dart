import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethodType;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      final isValid = await _validateCartUseCase(accountId: currentAccountId);
      if (isValid) {
        emit(state.copyWith(
          status: CheckoutRequestStatus.readyToPay,
          clearErrorMessage: true,
        ));
      } else {
        emit(state.copyWith(
          status: CheckoutRequestStatus.failure,
          errorMessage: 'Cart validation failed. Please check your cart.',
        ));
      }
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

  Future<void> placeOrder({required String address}) async {
    if (state.status != CheckoutRequestStatus.readyToPay) {
      return;
    }

    emit(state.copyWith(
      status: CheckoutRequestStatus.creatingOrder,
      clearErrorMessage: true,
    ));

    try {
      final order = await _createOrderUseCase(
        accountId: state.accountId,
        paymentMethod: state.selectedMethod.apiValue,
        address: address,
      );

      emit(state.copyWith(
        status: CheckoutRequestStatus.creatingPaymentIntent,
        orderId: order.orderId,
        orderReference: order.reference,
      ));

      final session = await _createPaymentSessionUseCase(
        orderId: order.orderId,
        paymentMethod: state.selectedMethod.apiValue,
      );

      if (state.selectedMethod.apiValue == 'CARD' && session.clientSecret != null) {
        try {
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: session.clientSecret,
              merchantDisplayName: 'Customer Ordering System',
            ),
          );
          
          await Stripe.instance.presentPaymentSheet();
          
          emit(state.copyWith(
            status: CheckoutRequestStatus.processing,
            paymentId: session.paymentId,
            paymentMessage: 'Payment submitted. Waiting for confirmation.',
          ));
          await refreshPaymentStatus();
        } on StripeException catch (e) {
          emit(state.copyWith(
            status: CheckoutRequestStatus.failure,
            errorMessage: e.error.localizedMessage ?? 'Payment cancelled or failed.',
            paymentId: session.paymentId,
          ));
        } catch (e) {
          emit(state.copyWith(
            status: CheckoutRequestStatus.failure,
            errorMessage: e.toString(),
            paymentId: session.paymentId,
          ));
        }
      } else {
        emit(state.copyWith(
          status: CheckoutRequestStatus.awaitingPayment,
          paymentId: session.paymentId,
          paymentMessage: 'Payment session created. Waiting for confirmation.',
        ));
      }
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

      if (status.status == 'COMPLETED') {
        emit(state.copyWith(
          status: CheckoutRequestStatus.success,
          paymentMessage: status.message ?? 'Payment successful.',
        ));
      } else if (status.status == 'FAILED' || status.status == 'CANCELLED') {
        emit(state.copyWith(
          status: CheckoutRequestStatus.failure,
          paymentMessage: status.message ?? 'Payment failed.',
          errorMessage: status.message ?? 'Payment failed.',
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
