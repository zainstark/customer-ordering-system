import 'package:flutter/foundation.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/checkout/data/models/checkout_models.dart';

abstract class CheckoutRemoteDataSource {
  Future<bool> validateCart({required String accountId});

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
  Future<bool> validateCart({required String accountId}) async {
    try {
      final response = await _dioClient.post('/api/cart/validate/');
      return response.data['is_valid'] == true;
    } catch (e) {
      throw AppException(message: 'Failed to validate cart: $e');
    }
  }

  @override
  Future<CreateOrderResponseModel> createOrder({
    required CreateOrderRequestModel request,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/order/place/',
        data: request.toMap(),
      );
      return CreateOrderResponseModel(
        orderId: response.data['orderId'],
        amount: (response.data['totalAmount'] as num).toDouble(),
        reference: response.data['orderId'], // Map to orderId since reference is not in response
      );
    } catch (e) {
      throw AppException(message: 'Failed to create order: $e');
    }
  }

  @override
  Future<CreatePaymentSessionResponseModel> createPaymentSession({
    required CreatePaymentSessionRequestModel request,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/payments/create-session/',
        data: request.toMap(),
      );
      return CreatePaymentSessionResponseModel.fromMap(response.data);
    } catch (e) {
      throw AppException(message: 'Failed to create payment session: $e');
    }
  }

  @override
  Future<PaymentStatusResponseModel> getPaymentStatus({
    required String paymentId,
  }) async {
    try {
      final response = await _dioClient.get('/api/payments/$paymentId/status/');
      return PaymentStatusResponseModel.fromMap(response.data);
    } catch (e) {
      throw AppException(message: 'Failed to fetch payment status: $e');
    }
  }

  @override
  Future<PaymentStatusResponseModel> retryPayment({
    required String paymentId,
  }) async {
    try {
      final response = await _dioClient.post('/api/payments/$paymentId/retry/');
      return PaymentStatusResponseModel.fromMap(response.data);
    } catch (e) {
      throw AppException(message: 'Failed to retry payment: $e');
    }
  }
}
