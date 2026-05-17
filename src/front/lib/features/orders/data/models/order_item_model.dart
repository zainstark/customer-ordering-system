import 'dart:convert';

import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.accountId,
    required super.orderId,
    required super.status,
    required super.placedAt,
    required super.totalAmount,
    required super.progress,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'accountId': accountId,
      'orderId': orderId,
      'status': status,
      'placedAt': placedAt.toIso8601String(),
      'totalAmount': totalAmount,
      'progress': progress,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    // API contract uses camelCase keys. Accept both snake_case and camelCase
    // and normalize fields. Ensure status is uppercase (PENDING etc.).
    final orderIdVal = (map['orderId'] ?? map['order_id'] ?? map['id']) as String;
    final idVal = (map['id'] ?? map['orderId'] ?? map['order_id']) as String;
    final accountIdVal = (map['accountId'] ?? map['account_id']) as String;
    final statusVal = ((map['status'] ?? map['order_status'] ?? '') as String).toUpperCase();
    final placedAtRaw = (map['placedAt'] ?? map['placed_at']) as String;
    final totalAmountVal = (map['totalAmount'] ?? map['total_amount']) as num;
    final progressVal = (map['progress'] ?? 0) as num;

    return OrderItemModel(
      id: idVal,
      accountId: accountIdVal,
      orderId: orderIdVal,
      status: statusVal,
      placedAt: DateTime.parse(placedAtRaw),
      totalAmount: totalAmountVal.toDouble(),
      progress: progressVal.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromJson(String source) =>
      OrderItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
