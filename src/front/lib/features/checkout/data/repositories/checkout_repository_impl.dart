import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
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
  Future<List<CartItemEntity>> validateCart({required String accountId}) async {
    final response = await _remoteDataSource.validateCart(accountId: accountId);
    return response;
  }

  @override
  Future<CheckoutOrderEntity> createOrder({
    required String accountId,
    required String paymentMethod,
    required double amount,
    required List<CartItemEntity> items,
  }) async {
    final request = CreateOrderRequestModel(
      accountId: accountId,
      paymentMethod: paymentMethod,
      amount: amount,
      items: items
          .map((item) => {
                'id': item.id,
                'cartId': item.cartId,
                'menuItemId': item.menuItemId,
                'title': item.title,
                'subtitle': item.subtitle,
                'unitPrice': item.unitPrice,
                'quantity': item.quantity,
                'imageUrl': item.imageUrl,
              })
          .toList(),
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
    required double amount,
  }) async {
    final request = CreatePaymentSessionRequestModel(
      orderId: orderId,
      paymentMethod: paymentMethod,
      amount: amount,
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
