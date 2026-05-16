import 'package:frontend/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Fetch paginated notifications from the backend
  Future<List<NotificationModel>> getNotifications({
    required int page,
    int limit = 10,
  });

  /// Get the count of unread notifications
  Future<int> getUnreadCount();

  /// Mark a single notification as read on the backend
  Future<NotificationModel> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read on the backend
  Future<bool> markAllAsRead();
}
