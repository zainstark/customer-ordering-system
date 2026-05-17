import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  const MarkNotificationAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<NotificationEntity> call(String notificationId) {
    return _repository.markNotificationAsRead(notificationId);
  }
}
