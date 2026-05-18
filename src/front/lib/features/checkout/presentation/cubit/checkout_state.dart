import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';

enum CheckoutRequestStatus {
  initial,
  loading,
  validatingCart,
  readyToPay,
  creatingOrder,
  creatingPaymentIntent,
  awaitingPayment,
  processing,
  success,
  failure,
  timeout,
}

enum PaymentMethodType { applePay, payPal, cash, card }

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get apiValue {
    switch (this) {
      case PaymentMethodType.applePay:
      case PaymentMethodType.payPal:
      case PaymentMethodType.card:
        return 'CARD';
      case PaymentMethodType.cash:
        return 'CASH';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.payPal:
        return 'PayPal';
      case PaymentMethodType.cash:
        return 'Cash on Delivery';
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
    }
  }

  String get iconName {
    switch (this) {
      case PaymentMethodType.applePay:
        return 'apple';
      case PaymentMethodType.payPal:
        return 'payments';
      case PaymentMethodType.cash:
        return 'payments';
      case PaymentMethodType.card:
        return 'credit_card';
    }
  }
}

class CheckoutState {
  const CheckoutState({
    required this.accountId,
    this.status = CheckoutRequestStatus.initial,
    this.selectedMethod = PaymentMethodType.applePay,
    this.orderId,
    this.paymentId,
    this.orderReference,
    this.paymentMessage,
    this.errorMessage,
  });

  final String accountId;
  final CheckoutRequestStatus status;
  final PaymentMethodType selectedMethod;
  final String? orderId;
  final String? paymentId;
  final String? orderReference;
  final String? paymentMessage;
  final String? errorMessage;

  CheckoutState copyWith({
    String? accountId,
    CheckoutRequestStatus? status,
    PaymentMethodType? selectedMethod,
    String? orderId,
    String? paymentId,
    String? orderReference,
    String? paymentMessage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CheckoutState(
      accountId: accountId ?? this.accountId,
      status: status ?? this.status,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      orderId: orderId ?? this.orderId,
      paymentId: paymentId ?? this.paymentId,
      orderReference: orderReference ?? this.orderReference,
      paymentMessage: clearErrorMessage ? null : paymentMessage ?? this.paymentMessage,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
