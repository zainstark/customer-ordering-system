import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/notifications/data/datasources/notification_remote_data_source_impl.dart';
import 'package:frontend/features/notifications/data/models/notification_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

void main() {
  late _MockDioClient dioClient;
  late NotificationRemoteDataSourceImpl dataSource;

  setUp(() {
    dioClient = _MockDioClient();
    dataSource = NotificationRemoteDataSourceImpl(dioClient);
  });

  group('NotificationRemoteDataSourceImpl', () {
    test('getNotifications maps the list response', () async {
      const endpoint = '/api/notifications/list';
      final responseBody = {
        'notifications': [
          {
            'message_id': 'notification-1',
            'subject': 'Ready',
            'body': 'Your order is ready',
            'delivery_channel': 'IN_APP',
            'delivery_status': 'PENDING',
            'created_at': '2025-01-01T12:00:00.000Z',
          },
        ],
      };

      when(() => dioClient.get(
            endpoint,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          data: responseBody,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getNotifications(page: 2, limit: 25);

      expect(result, hasLength(1));
      expect(result.first, isA<NotificationModel>());
      expect(result.first.messageId, 'notification-1');
      verify(() => dioClient.get(
            endpoint,
            queryParameters: {'page': 2, 'limit': 25},
          )).called(1);
    });

    test('getUnreadCount returns the unread count from the response', () async {
      const endpoint = '/api/notifications/unread-count';

      when(() => dioClient.get(endpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          data: {'unreadCount': 7},
          statusCode: 200,
        ),
      );

      final result = await dataSource.getUnreadCount();

      expect(result, 7);
      verify(() => dioClient.get(endpoint)).called(1);
    });

    test('markNotificationAsRead maps the updated notification', () async {
      const notificationId = 'notification-9';
      const endpoint = '/api/notifications/$notificationId/read';
      final responseBody = {
        'message_id': notificationId,
        'subject': 'Updated',
        'body': 'Updated body',
        'delivery_channel': 'IN_APP',
        'delivery_status': 'DELIVERED',
        'created_at': '2025-01-01T12:00:00.000Z',
      };

      when(() => dioClient.patch(endpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          data: responseBody,
          statusCode: 200,
        ),
      );

      final result = await dataSource.markNotificationAsRead(notificationId);

      expect(result.messageId, notificationId);
      expect(result.deliveryStatus, isNot(equals(null)));
      verify(() => dioClient.patch(endpoint)).called(1);
    });

    test('markAllAsRead reads the success flag', () async {
      const endpoint = '/api/notifications/mark-all-read';

      when(() => dioClient.patch(endpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: endpoint),
          data: {'success': true},
          statusCode: 200,
        ),
      );

      final result = await dataSource.markAllAsRead();

      expect(result, isTrue);
      verify(() => dioClient.patch(endpoint)).called(1);
    });
  });
}