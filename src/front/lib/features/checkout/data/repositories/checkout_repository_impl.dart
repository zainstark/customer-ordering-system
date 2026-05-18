import 'package:frontend/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:frontend/features/checkout/domain/entities/checkout_order_entity.dart';
import 'package:frontend/features/checkout/domain/entities/payment_session_entity.dart';
import 'package:frontend/features/checkout/domain/entities/payment_status_entity.dart';
import 'package:frontend/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:frontend/features/checkout/data/models/checkout_models.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._remoteDataSource);

  final CheckoutRemoteDataSource _remoteDataSource;

  @override
  Future<bool> validateCart({required String accountId}) async {
    return _remoteDataSource.validateCart(accountId: accountId);
  }

  @override
  Future<CheckoutOrderEntity> createOrder({
    required String accountId,
    required String paymentMethod,
    required String address,
  }) async {
    final request = CreateOrderRequestModel(
      accountId: accountId,
      paymentMethod: paymentMethod,
      address: address,
    );
    final response = await _remoteDataSource.createOrder(request: request);
    return CheckoutOrderEntity(
      orderId: response.orderId,
      reference: response.reference,
      amount: response.amount,
    );
  }

  @override
  Future<PaymentSessionEntity> createPaymentSession({
    required String orderId,
    required String paymentMethod,
  }) async {
    final request = CreatePaymentSessionRequestModel(
      orderId: orderId,
      paymentMethod: paymentMethod,
    );
    final response = await _remoteDataSource.createPaymentSession(request: request);
    return PaymentSessionEntity(
      paymentId: response.paymentId,
      checkoutUrl: response.checkoutUrl,
      status: response.status,
    );
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus({required String paymentId}) async {
    final response = await _remoteDataSource.getPaymentStatus(paymentId: paymentId);
    return PaymentStatusEntity(
      paymentId: response.paymentId,
      status: response.status,
      message: response.message,
    );
  }

  @override
  Future<PaymentStatusEntity> retryPayment({required String paymentId}) async {
    final response = await _remoteDataSource.retryPayment(paymentId: paymentId);
    return PaymentStatusEntity(
      paymentId: response.paymentId,
      status: response.status,
      message: response.message,
    );
  }
}
