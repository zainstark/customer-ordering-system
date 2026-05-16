import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.messageId,
    required super.subject,
    required super.body,
    required super.deliveryChannel,
    required super.deliveryStatus,
    required super.createdAt,
    super.sentAt,
    super.orderId,
  });

  /// Create a NotificationModel from a JSON map (from API response)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      messageId: json['message_id'] as String? ?? json['messageId'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
      deliveryChannel:
          _parseDeliveryChannel(json['delivery_channel'] as String?),
      deliveryStatus: _parseDeliveryStatus(json['delivery_status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      orderId: json['order_id'] as String?,
    );
  }

  /// Convert this model to a JSON map (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'subject': subject,
      'body': body,
      'delivery_channel': _deliveryChannelToString(deliveryChannel),
      'delivery_status': _deliveryStatusToString(deliveryStatus),
      'created_at': createdAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'order_id': orderId,
    };
  }

  /// Create a copy of this model with some fields replaced
  NotificationModel copyWith({
    String? messageId,
    String? subject,
    String? body,
    NotificationDeliveryChannel? deliveryChannel,
    NotificationDeliveryStatus? deliveryStatus,
    DateTime? createdAt,
    DateTime? sentAt,
    String? orderId,
  }) {
    return NotificationModel(
      messageId: messageId ?? this.messageId,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      deliveryChannel: deliveryChannel ?? this.deliveryChannel,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      orderId: orderId ?? this.orderId,
    );
  }

  /// Parse delivery channel from API string
  static NotificationDeliveryChannel _parseDeliveryChannel(String? value) {
    switch (value?.toUpperCase()) {
      case 'EMAIL':
        return NotificationDeliveryChannel.email;
      case 'SMS':
        return NotificationDeliveryChannel.sms;
      case 'WHATSAPP':
        return NotificationDeliveryChannel.whatsapp;
      case 'IN_APP':
      default:
        return NotificationDeliveryChannel.inApp;
    }
  }

  /// Convert delivery channel enum to API string
  static String _deliveryChannelToString(NotificationDeliveryChannel channel) {
    switch (channel) {
      case NotificationDeliveryChannel.email:
        return 'EMAIL';
      case NotificationDeliveryChannel.sms:
        return 'SMS';
      case NotificationDeliveryChannel.whatsapp:
        return 'WHATSAPP';
      case NotificationDeliveryChannel.inApp:
        return 'IN_APP';
    }
  }

  /// Parse delivery status from API string
  static NotificationDeliveryStatus _parseDeliveryStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return NotificationDeliveryStatus.pending;
      case 'SENT':
        return NotificationDeliveryStatus.sent;
      case 'FAILED':
        return NotificationDeliveryStatus.failed;
      case 'DELIVERED':
      default:
        return NotificationDeliveryStatus.delivered;
    }
  }

  /// Convert delivery status enum to API string
  static String _deliveryStatusToString(NotificationDeliveryStatus status) {
    switch (status) {
      case NotificationDeliveryStatus.pending:
        return 'PENDING';
      case NotificationDeliveryStatus.sent:
        return 'SENT';
      case NotificationDeliveryStatus.failed:
        return 'FAILED';
      case NotificationDeliveryStatus.delivered:
        return 'DELIVERED';
    }
  }
}

