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
    return OrderItemModel(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      orderId: map['orderId'] as String,
      status: map['status'] as String,
      placedAt: DateTime.parse(map['placedAt'] as String),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      progress: (map['progress'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromJson(String source) =>
      OrderItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
