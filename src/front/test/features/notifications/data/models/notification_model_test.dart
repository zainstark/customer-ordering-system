import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/data/models/notification_model.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson parses API payload fields', () {
      final model = NotificationModel.fromJson({
        'message_id': 'notification-1',
        'subject': 'Order updated',
        'body': 'Your order is on the way',
        'delivery_channel': 'in_app',
        'delivery_status': 'pending',
        'created_at': '2025-01-01T12:00:00.000Z',
        'sent_at': '2025-01-01T12:05:00.000Z',
        'order_id': 'order-99',
      });

      expect(model.messageId, 'notification-1');
      expect(model.subject, 'Order updated');
      expect(model.body, 'Your order is on the way');
      expect(model.deliveryChannel, NotificationDeliveryChannel.inApp);
      expect(model.deliveryStatus, NotificationDeliveryStatus.pending);
      expect(model.createdAt.toUtc(), DateTime.parse('2025-01-01T12:00:00.000Z'));
      expect(model.sentAt?.toUtc(), DateTime.parse('2025-01-01T12:05:00.000Z'));
      expect(model.orderId, 'order-99');
    });

    test('toJson serializes the model back to api shape', () {
      final model = NotificationModel(
        messageId: 'notification-2',
        subject: 'Ready',
        body: 'Your meal is ready',
        deliveryChannel: NotificationDeliveryChannel.email,
        deliveryStatus: NotificationDeliveryStatus.delivered,
        createdAt: DateTime.parse('2025-01-02T08:00:00.000Z'),
        sentAt: DateTime.parse('2025-01-02T08:05:00.000Z'),
        orderId: 'order-101',
      );

      expect(model.toJson(), {
        'message_id': 'notification-2',
        'subject': 'Ready',
        'body': 'Your meal is ready',
        'delivery_channel': 'EMAIL',
        'delivery_status': 'DELIVERED',
        'created_at': '2025-01-02T08:00:00.000Z',
        'sent_at': '2025-01-02T08:05:00.000Z',
        'order_id': 'order-101',
      });
    });

    test('copyWith preserves unchanged fields', () {
      final original = NotificationModel(
        messageId: 'notification-3',
        subject: 'Original',
        body: 'Body',
        deliveryChannel: NotificationDeliveryChannel.sms,
        deliveryStatus: NotificationDeliveryStatus.sent,
        createdAt: DateTime(2025, 1, 3, 10, 0),
      );

      final updated = original.copyWith(
        subject: 'Updated',
        deliveryStatus: NotificationDeliveryStatus.delivered,
      );

      expect(updated.messageId, 'notification-3');
      expect(updated.subject, 'Updated');
      expect(updated.body, 'Body');
      expect(updated.deliveryChannel, NotificationDeliveryChannel.sms);
      expect(updated.deliveryStatus, NotificationDeliveryStatus.delivered);
      expect(updated.createdAt, original.createdAt);
    });
  });
}