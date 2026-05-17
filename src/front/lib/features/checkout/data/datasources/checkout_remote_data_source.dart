import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/cart/data/models/cart_item_model.dart';
import 'package:frontend/features/checkout/data/models/checkout_models.dart';

abstract class CheckoutRemoteDataSource {
  Future<List<CartItemModel>> validateCart({required String accountId});

  Future<CreateOrderResponseModel> createOrder({
    required CreateOrderRequestModel request,
  });

  Future<CreatePaymentSessionResponseModel> createPaymentSession({
    required CreatePaymentSessionRequestModel request,
  });

  Future<PaymentStatusResponseModel> getPaymentStatus({
    required String paymentId,
  });

  Future<PaymentStatusResponseModel> retryPayment({
    required String paymentId,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<CartItemModel>> validateCart({required String accountId}) async {
    debugPrint('🚦 checkout.validateCart accountId: $accountId');
    await Future.delayed(const Duration(milliseconds: 900));

    if (accountId.isEmpty) {
      throw const AppException(message: 'Account id is required for checkout.');
    }

    // Mock validation response using a static cart snapshot.
    final items = [
      CartItemModel(
        id: 'cart_item_001',
        cartId: 'cart_001',
        menuItemId: 'menu_item_001',
        title: 'Truffle Umami Burger',
        subtitle: 'Handcrafted premium beef with garlic aioli.',
        unitPrice: 18.5,
        quantity: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=400&q=80',
      ),
      CartItemModel(
        id: 'cart_item_002',
        cartId: 'cart_001',
        menuItemId: 'menu_item_002',
        title: 'Spicy Diavola Pizza',
        subtitle: 'Stone-baked pizza with chili oil and fresh basil.',
        unitPrice: 22.0,
        quantity: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1548365328-87824c4d3a2f?auto=format&fit=crop&w=400&q=80',
      ),
    ];

    return items;
  }

  @override
  Future<CreateOrderResponseModel> createOrder({
    required CreateOrderRequestModel request,
  }) async {
    debugPrint('🧾 checkout.createOrder request: ${request.toMap()}');
    await Future.delayed(const Duration(seconds: 1));

    return CreateOrderResponseModel(
      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      amount: request.amount,
      reference: 'REF${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
  }

  @override
  Future<CreatePaymentSessionResponseModel> createPaymentSession({
    required CreatePaymentSessionRequestModel request,
  }) async {
    debugPrint('💳 checkout.createPaymentSession request: ${request.toMap()}');
    await Future.delayed(const Duration(milliseconds: 1100));

    return CreatePaymentSessionResponseModel(
      paymentId: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      checkoutUrl: 'https://checkout.example.com/session/${request.orderId}',
      status: 'pending',
    );
  }

  @override
  Future<PaymentStatusResponseModel> getPaymentStatus({
    required String paymentId,
  }) async {
    debugPrint('⏳ checkout.getPaymentStatus paymentId: $paymentId');
    await Future.delayed(const Duration(seconds: 1));

    final progress = DateTime.now().second % 3;
    if (progress == 0) {
      return PaymentStatusResponseModel(
        paymentId: paymentId,
        status: 'processing',
        message: 'Waiting for bank confirmation.',
      );
    }

    if (progress == 1) {
      return PaymentStatusResponseModel(
        paymentId: paymentId,
        status: 'success',
        message: 'Payment verified successfully.',
      );
    }

    return PaymentStatusResponseModel(
      paymentId: paymentId,
      status: 'failed',
      message: 'Payment could not be completed. Please retry.',
    );
  }

  @override
  Future<PaymentStatusResponseModel> retryPayment({
    required String paymentId,
  }) async {
    debugPrint('🔁 checkout.retryPayment paymentId: $paymentId');
    await Future.delayed(const Duration(milliseconds: 800));

    return PaymentStatusResponseModel(
      paymentId: paymentId,
      status: 'processing',
      message: 'Retry initiated. Please wait.',
    );
  }
}
