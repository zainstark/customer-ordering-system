import 'package:dio/dio.dart';
import 'package:frontend/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:frontend/features/notifications/data/models/notification_model.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const String _baseUrl = '/api/notifications';

  @override
  Future<List<NotificationModel>> getNotifications({
    required int page,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/list',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['notifications'] ?? [];
        return jsonList
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching notifications: ${e.message}');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('$_baseUrl/unread-count');

      if (response.statusCode == 200) {
        return response.data['unreadCount'] as int? ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching unread count: ${e.message}');
    }
  }

  @override
  Future<NotificationModel> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/$notificationId/read',
      );

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error marking notification as read: ${e.message}');
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.patch('$_baseUrl/mark-all-read');

      if (response.statusCode == 200) {
        return response.data['success'] as bool? ?? true;
      } else {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error marking all as read: ${e.message}');
    }
  }
}

/// Mock implementation for testing and development without a real backend
class NotificationRemoteDataSourceMock implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceMock() {
    _initMockData();
  }

  final List<NotificationModel> _mockNotifications = [];

  void _initMockData() {
    final now = DateTime.now();

    _mockNotifications.addAll([
      // Pending (unread in-app)
      NotificationModel(
        messageId: 'msg_001',
        subject: 'Order Delivered',
        body: 'Your burger order from Big Bun Grill has been delivered. Enjoy your meal!',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 2)),
        sentAt: now.subtract(const Duration(minutes: 2)),
        orderId: 'order_123',
      ),
      NotificationModel(
        messageId: 'msg_002',
        subject: 'Special Discount Available',
        body: 'Get 20% off on your next Sushi order. Valid for today only!',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.pending,
        createdAt: now.subtract(const Duration(hours: 1)),
        sentAt: now.subtract(const Duration(hours: 1)),
        orderId: null,
      ),
      NotificationModel(
        messageId: 'msg_003',
        subject: 'Order is on the way',
        body: 'Your order from Pizza Palace is being delivered by our courier.',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        sentAt: now.subtract(const Duration(hours: 2)),
        orderId: 'order_456',
      ),
      // Delivered (read in-app)
      NotificationModel(
        messageId: 'msg_004',
        subject: 'Weekly Summary',
        body: 'You saved \$45 last week with ZestyBite Pro. Keep it up!',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        sentAt: now.subtract(const Duration(days: 1, hours: 6)),
        orderId: null,
      ),
      NotificationModel(
        messageId: 'msg_005',
        subject: 'Security Alert',
        body: 'Your password was changed successfully. If this wasn\'t you, contact support.',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 1, hours: 10)),
        sentAt: now.subtract(const Duration(days: 1, hours: 10)),
        orderId: null,
      ),
      NotificationModel(
        messageId: 'msg_006',
        subject: 'Badge Earned!',
        body: 'You\'re now a "Frequent Foodie"! Unlock exclusive rewards.',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 7)),
        sentAt: now.subtract(const Duration(days: 7)),
        orderId: null,
      ),
      NotificationModel(
        messageId: 'msg_007',
        subject: 'Order Confirmed',
        body: 'Order #8842 has been confirmed. Estimated delivery: 45 minutes.',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 7, hours: 2)),
        sentAt: now.subtract(const Duration(days: 7, hours: 2)),
        orderId: 'order_789',
      ),
      NotificationModel(
        messageId: 'msg_008',
        subject: 'Flash Sale! 30% OFF',
        body: 'Use code ZESTY30 for your next pizza order. Valid for today only!',
        deliveryChannel: NotificationDeliveryChannel.inApp,
        deliveryStatus: NotificationDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 14)),
        sentAt: now.subtract(const Duration(days: 14)),
        orderId: null,
      ),
    ]);
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    required int page,
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, _mockNotifications.length);

    return _mockNotifications.sublist(
      startIndex,
      endIndex,
    ).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockNotifications
        .where((n) => n.deliveryStatus == NotificationDeliveryStatus.pending)
        .length;
  }

  @override
  Future<NotificationModel> markNotificationAsRead(String notificationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockNotifications.indexWhere((n) => n.messageId == notificationId);
    if (index == -1) {
      throw Exception('Notification not found');
    }

    _mockNotifications[index] = _mockNotifications[index].copyWith(
      deliveryStatus: NotificationDeliveryStatus.delivered,
    );
    return _mockNotifications[index];
  }

  @override
  Future<bool> markAllAsRead() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    for (int i = 0; i < _mockNotifications.length; i++) {
      if (_mockNotifications[i].deliveryStatus == NotificationDeliveryStatus.pending) {
        _mockNotifications[i] = _mockNotifications[i].copyWith(
          deliveryStatus: NotificationDeliveryStatus.delivered,
        );
      }
    }

    return true;
  }
}
