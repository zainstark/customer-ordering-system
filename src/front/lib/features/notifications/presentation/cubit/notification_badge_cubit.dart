import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_state.dart';

class NotificationBadgeCubit extends Cubit<NotificationBadgeState> {
  NotificationBadgeCubit(GetUnreadCountUseCase getUnreadCountUseCase)
      : _getUnreadCountUseCase = getUnreadCountUseCase,
        super(const NotificationBadgeState(
          unreadCount: 0,
          status: NotificationBadgeStatus.initial,
        ));

  final GetUnreadCountUseCase _getUnreadCountUseCase;

  /// Load the unread count from the backend
  Future<void> loadUnreadCount() async {
    emit(state.copyWith(status: NotificationBadgeStatus.loading));

    try {
      final count = await _getUnreadCountUseCase();
      emit(state.copyWith(
        unreadCount: count,
        status: NotificationBadgeStatus.success,
        clearErrorMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: NotificationBadgeStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Refresh unread count
  Future<void> refresh() async {
    await loadUnreadCount();
  }

  /// Decrement unread count by 1 (when user marks notification as read)
  void decrementUnreadCount() {
    if (state.unreadCount > 0) {
      emit(state.copyWith(unreadCount: state.unreadCount - 1));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const NotificationBadgeState(
      unreadCount: 0,
      status: NotificationBadgeStatus.initial,
    ));
  }
}
