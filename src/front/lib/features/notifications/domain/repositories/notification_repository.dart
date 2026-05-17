import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Fetch paginated notifications
  /// 
  /// Returns a list of [NotificationEntity] objects
  /// [page] starts from 1
  /// [limit] is the number of items per page (default 10)
  Future<List<NotificationEntity>> getNotifications({
    required int page,
    int limit = 10,
  });

  /// Get the count of unread notifications
  Future<int> getUnreadCount();

  /// Mark a single notification as read
  /// Returns the updated notification, or throws on error
  Future<NotificationEntity> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read
  /// Returns true on success
  Future<bool> markAllAsRead();
}
