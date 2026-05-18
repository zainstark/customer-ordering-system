import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_state.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';

NotificationEntity _notification({
  required String id,
  required NotificationDeliveryStatus status,
}) {
  return NotificationEntity(
    messageId: id,
    subject: 'Subject $id',
    body: 'Body $id',
    deliveryChannel: NotificationDeliveryChannel.inApp,
    deliveryStatus: status,
    createdAt: DateTime(2025, 1, 1, 12, 0),
  );
}

void main() {
  group('NotificationState', () {
    test('unreadCount only counts pending notifications', () {
      final state = NotificationState(
        notifications: [
          _notification(id: '1', status: NotificationDeliveryStatus.pending),
          _notification(id: '2', status: NotificationDeliveryStatus.delivered),
          _notification(id: '3', status: NotificationDeliveryStatus.pending),
        ],
        status: NotificationRequestStatus.success,
      );

      expect(state.unreadCount, 2);
    });

    test('copyWith clears error when requested', () {
      final state = NotificationState(
        notifications: const [],
        status: NotificationRequestStatus.error,
        errorMessage: 'failed',
        currentPage: 2,
        totalNotifications: 7,
        hasMorePages: true,
      );

      final updated = state.copyWith(
        status: NotificationRequestStatus.loading,
        clearErrorMessage: true,
      );

      expect(updated.status, NotificationRequestStatus.loading);
      expect(updated.errorMessage, isNull);
      expect(updated.currentPage, 2);
      expect(updated.totalNotifications, 7);
      expect(updated.hasMorePages, true);
    });
  });

  group('NotificationBadgeState', () {
    test('copyWith clears error when requested', () {
      final state = NotificationBadgeState(
        unreadCount: 4,
        status: NotificationBadgeStatus.error,
        errorMessage: 'bad network',
      );

      final updated = state.copyWith(
        unreadCount: 6,
        status: NotificationBadgeStatus.success,
        clearErrorMessage: true,
      );

      expect(updated.unreadCount, 6);
      expect(updated.status, NotificationBadgeStatus.success);
      expect(updated.errorMessage, isNull);
    });
  });
}