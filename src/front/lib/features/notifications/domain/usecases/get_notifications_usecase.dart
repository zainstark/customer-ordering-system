import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<List<NotificationEntity>> call({
    required int page,
    int limit = 10,
  }) {
    return _repository.getNotifications(page: page, limit: limit);
  }
}
