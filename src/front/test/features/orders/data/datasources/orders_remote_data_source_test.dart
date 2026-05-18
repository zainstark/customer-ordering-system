import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/Core/network/api_endpoints.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:frontend/features/orders/data/models/order_tracking_model.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late OrdersRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = OrdersRemoteDataSourceImpl(mockDioClient);
  });

  group('getOrderTracking', () {
    const tOrderId = 'test_order_id';
    final tEndpoint = ApiEndpoints.orderTracking.replaceFirst('{orderId}', tOrderId);

    final tJsonResponse = {
      'orderId': tOrderId,
      'currentStatus': 'pending',
      'progress': 0,
      'estimatedTimeMinutes': 45,
      'history': [
        {
          'status': 'pending',
          'timestamp': '2023-01-01T00:00:00.000Z',
        }
      ]
    };

    final tOrderTrackingModel = OrderTrackingModel.fromMap(tJsonResponse);

    test('should return OrderTrackingModel when the response code is 200 and format is valid', () async {
      // arrange
      when(() => mockDioClient.get(tEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: tEndpoint),
          statusCode: 200,
          data: tJsonResponse,
        ),
      );

      // act
      final result = await dataSource.getOrderTracking(tOrderId);

      // assert
      expect(result.orderId, equals(tOrderTrackingModel.orderId));
      expect(result.currentStatus, equals(tOrderTrackingModel.currentStatus));
      verify(() => mockDioClient.get(tEndpoint)).called(1);
    });

    test('should throw AppException when the response code is 200 but format is invalid', () async {
      // arrange
      when(() => mockDioClient.get(tEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: tEndpoint),
          statusCode: 200,
          data: [], // Invalid format, should be Map
        ),
      );

      // act
      final call = dataSource.getOrderTracking;

      // assert
      expect(() => call(tOrderId), throwsA(isA<AppException>()));
    });

    test('should throw AppException when the response code is not 200', () async {
      // arrange
      when(() => mockDioClient.get(tEndpoint)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: tEndpoint),
          statusCode: 404,
          statusMessage: 'Not Found',
        ),
      );

      // act
      final call = dataSource.getOrderTracking;

      // assert
      expect(() => call(tOrderId), throwsA(isA<AppException>()));
    });
  });
}
