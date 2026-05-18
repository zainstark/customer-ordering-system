import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/orders/data/models/order_tracking_model.dart';
import 'package:frontend/features/orders/domain/entities/order_tracking_entity.dart';

void main() {
  final tTrackingHistoryEntryModel = TrackingHistoryEntryModel(
    status: 'pending',
    timestamp: DateTime.parse('2023-01-01T00:00:00.000Z'),
  );

  final tOrderTrackingModel = OrderTrackingModel(
    orderId: 'test_order_id',
    currentStatus: 'pending',
    progress: 0,
    estimatedTimeMinutes: 45,
    history: [tTrackingHistoryEntryModel],
  );

  test('should be a subclass of OrderTrackingEntity', () async {
    expect(tOrderTrackingModel, isA<OrderTrackingEntity>());
  });

  group('fromMap', () {
    test('should return a valid model from JSON map', () async {
      final Map<String, dynamic> jsonMap = {
        'orderId': 'test_order_id',
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

      final result = OrderTrackingModel.fromMap(jsonMap);

      expect(result.orderId, tOrderTrackingModel.orderId);
      expect(result.currentStatus, tOrderTrackingModel.currentStatus);
      expect(result.progress, tOrderTrackingModel.progress);
      expect(result.estimatedTimeMinutes, tOrderTrackingModel.estimatedTimeMinutes);
      expect(result.history.length, 1);
      expect(result.history.first.status, tTrackingHistoryEntryModel.status);
      expect(result.history.first.timestamp, tTrackingHistoryEntryModel.timestamp);
    });
  });

  group('toMap', () {
    test('should return a JSON map containing proper data', () async {
      final result = tOrderTrackingModel.toMap();

      final expectedMap = {
        'orderId': 'test_order_id',
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

      expect(result, expectedMap);
    });
  });
}
