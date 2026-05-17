import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

enum NotificationRequestStatus { initial, loading, success, empty, error }

class NotificationState {
  const NotificationState({
    required this.notifications,
    required this.status,
    this.errorMessage,
    this.currentPage = 1,
    this.totalNotifications = 0,
    this.hasMorePages = false,
  });

  final List<NotificationEntity> notifications;
  final NotificationRequestStatus status;
  final String? errorMessage;
  final int currentPage;
  final int totalNotifications;
  final bool hasMorePages;

  /// Get unique unread count (pending delivery status)
  int get unreadCount => notifications
      .where((n) => n.deliveryStatus == NotificationDeliveryStatus.pending)
      .length;

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    NotificationRequestStatus? status,
    String? errorMessage,
    int? currentPage,
    int? totalNotifications,
    bool? hasMorePages,
    bool clearErrorMessage = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalNotifications: totalNotifications ?? this.totalNotifications,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  String toString() =>
      'NotificationState(notifications: ${notifications.length}, status: $status, unreadCount: $unreadCount, page: $currentPage)';
}

