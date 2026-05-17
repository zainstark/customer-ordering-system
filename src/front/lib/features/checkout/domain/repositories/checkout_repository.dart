import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/checkout/domain/entities/checkout_order_entity.dart';
import 'package:frontend/features/checkout/domain/entities/payment_session_entity.dart';
import 'package:frontend/features/checkout/domain/entities/payment_status_entity.dart';

abstract class CheckoutRepository {
  Future<List<CartItemEntity>> validateCart({required String accountId});

  Future<CheckoutOrderEntity> createOrder({
    required String accountId,
    required String paymentMethod,
    required double amount,
    required List<CartItemEntity> items,
  });

  Future<PaymentSessionEntity> createPaymentSession({
    required String orderId,
    required String paymentMethod,
    required double amount,
  });

  Future<PaymentStatusEntity> getPaymentStatus({required String paymentId});

  Future<PaymentStatusEntity> retryPayment({required String paymentId});
}
