import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';

class GetUnreadCountUseCase {
  const GetUnreadCountUseCase(this._repository);

  final NotificationRepository _repository;

  Future<int> call() {
    return _repository.getUnreadCount();
  }
}
