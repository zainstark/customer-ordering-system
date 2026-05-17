import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(
    GetNotificationsUseCase getNotificationsUseCase,
    MarkNotificationAsReadUseCase markAsReadUseCase,
    MarkAllAsReadUseCase markAllAsReadUseCase,
  )   : _getNotificationsUseCase = getNotificationsUseCase,
        _markAsReadUseCase = markAsReadUseCase,
        _markAllAsReadUseCase = markAllAsReadUseCase,
        super(
          const NotificationState(
            notifications: [],
            status: NotificationRequestStatus.initial,
          ),
        );

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final MarkAllAsReadUseCase _markAllAsReadUseCase;

  static const int _pageSize = 10;

  /// Load notifications for the given page
  /// If [isRefresh] is true, resets pagination and fetches page 1
  Future<void> loadNotifications({
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      emit(state.copyWith(
        status: NotificationRequestStatus.loading,
        currentPage: 1,
        notifications: [],
        clearErrorMessage: true,
      ));
    } else if (page == 1) {
      emit(state.copyWith(
        status: NotificationRequestStatus.loading,
        clearErrorMessage: true,
      ));
    }

    try {
      final notifications = await _getNotificationsUseCase(
        page: page,
        limit: _pageSize,
      );

      if (notifications.isEmpty && page == 1) {
        emit(state.copyWith(
          status: NotificationRequestStatus.empty,
          notifications: [],
          currentPage: 1,
        ));
      } else {
        // Append to existing list if not a refresh/first page
        final newList = page == 1
            ? notifications
            : [...state.notifications, ...notifications];

        emit(state.copyWith(
          notifications: newList,
          status: NotificationRequestStatus.success,
          currentPage: page,
          hasMorePages: notifications.length == _pageSize,
          clearErrorMessage: true,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: NotificationRequestStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final updatedNotification = await _markAsReadUseCase(notificationId);

      // Update the notification in the list
      final updatedList = state.notifications.map((n) {
        return n.messageId == notificationId ? updatedNotification : n;
      }).toList();

      emit(state.copyWith(notifications: updatedList));
    } catch (error) {
      // Log error but don't emit error state - this is a side effect
      // Could optionally emit a message to show snackbar
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _markAllAsReadUseCase();

      // Mark all in local state as read
      final updatedList = state.notifications
          .map((n) => n as NotificationEntity)
          .toList();

      // Update isRead on all
      final finalList = updatedList.map((n) {
        if (n is NotificationEntity) {
          // Create a modified version - we need to work with the base entity
          // Since entity is immutable, we'd need a copyWith method
          // For now, we'll update and re-fetch on next page load
          // Or we can cast to NotificationModel if available
          return n;
        }
        return n;
      }).toList();

      // For now, just re-fetch to get accurate state
      await loadNotifications(isRefresh: true);
    } catch (error) {
      // Log error but don't emit error state
    }
  }

  /// Load next page of notifications
  Future<void> loadMoreNotifications() async {
    if (!state.hasMorePages || state.status == NotificationRequestStatus.loading) {
      return;
    }

    await loadNotifications(page: state.currentPage + 1);
  }

  /// Refresh all notifications (goes back to page 1)
  Future<void> refresh() async {
    await loadNotifications(isRefresh: true);
  }

  /// Reset to initial state
  void reset() {
    emit(const NotificationState(
      notifications: [],
      status: NotificationRequestStatus.initial,
    ));
  }
}
