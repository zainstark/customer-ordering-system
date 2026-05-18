class CreateOrderRequestModel {
  CreateOrderRequestModel({
    required this.accountId,
    required this.paymentMethod,
    required this.address,
  });

  final String accountId;
  final String paymentMethod;
  final String address;

  Map<String, dynamic> toMap() {
    return {
      'account_id': accountId,
      'payment_method': paymentMethod,
      'address': address,
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
  });

  final String orderId;
  final String paymentMethod;

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'payment_method': paymentMethod,
    };
  }
}

class CreatePaymentSessionResponseModel {
  CreatePaymentSessionResponseModel({
    required this.paymentId,
    required this.checkoutUrl,
    required this.status,
    this.clientSecret,
  });

  final String paymentId;
  final String checkoutUrl;
  final String status;
  final String? clientSecret;

  factory CreatePaymentSessionResponseModel.fromMap(Map<String, dynamic> map) {
    return CreatePaymentSessionResponseModel(
      paymentId: map['payment_id'] as String,
      checkoutUrl: map['checkout_url'] as String,
      status: map['status'] as String,
      clientSecret: map['client_secret'] as String?,
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
