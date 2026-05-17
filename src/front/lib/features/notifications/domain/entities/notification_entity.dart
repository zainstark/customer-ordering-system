import 'package:equatable/equatable.dart';

enum NotificationDeliveryChannel { email, sms, inApp, whatsapp }

enum NotificationDeliveryStatus { pending, sent, failed, delivered }

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.messageId,
    required this.subject,
    required this.body,
    required this.deliveryChannel,
    required this.deliveryStatus,
    required this.createdAt,
    this.sentAt,
    this.orderId,
  });

  final String messageId;
  final String subject;
  final String body;
  final NotificationDeliveryChannel deliveryChannel;
  final NotificationDeliveryStatus deliveryStatus;
  final DateTime createdAt;
  final DateTime? sentAt;
  final String? orderId;

  /// For UI purposes: treat successfully sent/delivered in-app notifications as "read"
  bool get isRead => deliveryStatus == NotificationDeliveryStatus.delivered ||
      deliveryStatus == NotificationDeliveryStatus.sent;

  @override
  List<Object?> get props => [
        messageId,
        subject,
        body,
        deliveryChannel,
        deliveryStatus,
        createdAt,
        sentAt,
        orderId,
      ];
}

