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
  String get label {
    switch (this) {
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.payPal:
        return 'PayPal';
      case PaymentMethodType.cash:
        return 'Cash';
      case PaymentMethodType.card:
        return 'Visa •••• 4242';
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
    this.items = const [],
    this.status = CheckoutRequestStatus.initial,
    this.selectedMethod = PaymentMethodType.applePay,
    this.orderId,
    this.paymentId,
    this.orderReference,
    this.paymentMessage,
    this.errorMessage,
  });

  final String accountId;
  final List<CartItemEntity> items;
  final CheckoutRequestStatus status;
  final PaymentMethodType selectedMethod;
  final String? orderId;
  final String? paymentId;
  final String? orderReference;
  final String? paymentMessage;
  final String? errorMessage;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));

  double get deliveryFee => items.isEmpty ? 0 : 2.99;

  double get taxes => subtotal * 0.09;

  double get total => subtotal + deliveryFee + taxes;

  bool get hasItems => items.isNotEmpty;

  CheckoutState copyWith({
    String? accountId,
    List<CartItemEntity>? items,
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
      items: items ?? this.items,
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
