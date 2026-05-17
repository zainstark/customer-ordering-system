class CreateOrderRequestModel {
  CreateOrderRequestModel({
    required this.accountId,
    required this.paymentMethod,
    required this.amount,
    required this.items,
  });

  final String accountId;
  final String paymentMethod;
  final double amount;
  final List<Map<String, dynamic>> items;

  Map<String, dynamic> toMap() {
    return {
      'account_id': accountId,
      'payment_method': paymentMethod,
      'amount': amount,
      'items': items,
    };
  }
}

class CreateOrderResponseModel {
  CreateOrderResponseModel({
    required this.orderId,
    required this.amount,
    required this.reference,
  });

  final String orderId;
  final double amount;
  final String reference;

  factory CreateOrderResponseModel.fromMap(Map<String, dynamic> map) {
    return CreateOrderResponseModel(
      orderId: map['order_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      reference: map['reference'] as String,
    );
  }
}

class CreatePaymentSessionRequestModel {
  CreatePaymentSessionRequestModel({
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
  });

  final String orderId;
  final String paymentMethod;
  final double amount;

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
    };
  }
}

class CreatePaymentSessionResponseModel {
  CreatePaymentSessionResponseModel({
    required this.paymentId,
    required this.checkoutUrl,
    required this.status,
  });

  final String paymentId;
  final String checkoutUrl;
  final String status;

  factory CreatePaymentSessionResponseModel.fromMap(Map<String, dynamic> map) {
    return CreatePaymentSessionResponseModel(
      paymentId: map['payment_id'] as String,
      checkoutUrl: map['checkout_url'] as String,
      status: map['status'] as String,
    );
  }
}

class PaymentStatusResponseModel {
  PaymentStatusResponseModel({
    required this.paymentId,
    required this.status,
    required this.message,
  });

  final String paymentId;
  final String status;
  final String? message;

  factory PaymentStatusResponseModel.fromMap(Map<String, dynamic> map) {
    return PaymentStatusResponseModel(
      paymentId: map['payment_id'] as String,
      status: map['status'] as String,
      message: map['message'] as String?,
    );
  }
}
