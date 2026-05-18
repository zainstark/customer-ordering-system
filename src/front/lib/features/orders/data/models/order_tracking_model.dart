import 'dart:convert';

import 'package:frontend/features/orders/domain/entities/order_tracking_entity.dart';

class TrackingHistoryEntryModel extends TrackingHistoryEntry {
  const TrackingHistoryEntryModel({
    required super.status,
    required super.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TrackingHistoryEntryModel.fromMap(Map<String, dynamic> map) {
    return TrackingHistoryEntryModel(
      status: map['status'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory TrackingHistoryEntryModel.fromJson(String source) =>
      TrackingHistoryEntryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class OrderTrackingModel extends OrderTrackingEntity {
  const OrderTrackingModel({
    required super.orderId,
    required super.currentStatus,
    required super.progress,
    required super.estimatedTimeMinutes,
    required super.history,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'currentStatus': currentStatus,
      'progress': progress,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'history': history.map((e) => (e as TrackingHistoryEntryModel).toMap()).toList(),
    };
  }

  factory OrderTrackingModel.fromMap(Map<String, dynamic> map) {
    final historyRaw = (map['history'] ?? []) as List<dynamic>;
    final historyList = historyRaw
        .map((i) => TrackingHistoryEntryModel.fromMap(i as Map<String, dynamic>))
        .toList();

    return OrderTrackingModel(
      orderId: map['orderId'] as String,
      currentStatus: map['currentStatus'] as String,
      progress: (map['progress'] as num).toInt(),
      estimatedTimeMinutes: (map['estimatedTimeMinutes'] as num).toInt(),
      history: historyList,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderTrackingModel.fromJson(String source) =>
      OrderTrackingModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
