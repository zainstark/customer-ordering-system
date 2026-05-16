import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllAsReadUseCase {
  const MarkAllAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<bool> call() {
    return _repository.markAllAsRead();
  }
}
