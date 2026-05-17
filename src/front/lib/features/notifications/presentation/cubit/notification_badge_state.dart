enum NotificationBadgeStatus { initial, loading, success, error }

class NotificationBadgeState {
  const NotificationBadgeState({
    required this.unreadCount,
    required this.status,
    this.errorMessage,
  });

  final int unreadCount;
  final NotificationBadgeStatus status;
  final String? errorMessage;

  NotificationBadgeState copyWith({
    int? unreadCount,
    NotificationBadgeStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationBadgeState(
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'NotificationBadgeState(unreadCount: $unreadCount, status: $status)';
}
