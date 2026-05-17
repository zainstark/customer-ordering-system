import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:frontend/features/notifications/data/models/notification_model.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  static const String _baseUrl = '/api/notifications';

  @override
  Future<List<NotificationModel>> getNotifications({
    required int page,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      '$_baseUrl/list',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List<dynamic> jsonList = response.data['notifications'] ?? [];
    return jsonList
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dioClient.get('$_baseUrl/unread-count');
    return response.data['unreadCount'] as int? ?? 0;
  }

  @override
  Future<NotificationModel> markNotificationAsRead(String notificationId) async {
    final response = await _dioClient.patch('$_baseUrl/$notificationId/read');
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> markAllAsRead() async {
    final response = await _dioClient.patch('$_baseUrl/mark-all-read');
    return response.data['success'] as bool? ?? true;
  }
}
