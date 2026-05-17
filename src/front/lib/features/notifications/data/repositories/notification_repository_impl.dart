import 'package:frontend/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<NotificationEntity>> getNotifications({
    required int page,
    int limit = 10,
  }) {
    return _remoteDataSource.getNotifications(page: page, limit: limit);
  }

  @override
  Future<int> getUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }

  @override
  Future<NotificationEntity> markNotificationAsRead(String notificationId) {
    return _remoteDataSource.markNotificationAsRead(notificationId);
  }

  @override
  Future<bool> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }
}
