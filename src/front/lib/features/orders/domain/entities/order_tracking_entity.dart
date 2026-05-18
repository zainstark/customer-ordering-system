class TrackingHistoryEntry {
  const TrackingHistoryEntry({
    required this.status,
    required this.timestamp,
  });

  final String status;
  final DateTime timestamp;
}

class OrderTrackingEntity {
  const OrderTrackingEntity({
    required this.orderId,
    required this.currentStatus,
    required this.progress,
    required this.estimatedTimeMinutes,
    required this.history,
  });

  final String orderId;
  final String currentStatus;
  final int progress;
  final int estimatedTimeMinutes;
  final List<TrackingHistoryEntry> history;
}
