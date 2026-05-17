import 'package:frontend/features/orders/domain/entities/order_line_item_entity.dart';

class OrderLineItemModel extends OrderLineItemEntity {
  const OrderLineItemModel({
    required super.id,
    required super.title,
    required super.unitPrice,
    required super.quantity,
    required super.lineTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
    };
  }

  factory OrderLineItemModel.fromMap(Map<String, dynamic> map) {
    final unitPriceNum = (map['unitPrice'] ?? map['unit_price']) as num;
    final lineTotalNum = (map['lineTotal'] ?? map['line_total']) as num;

    return OrderLineItemModel(
      id: map['id'] as String,
      title: map['title'] as String,
      unitPrice: unitPriceNum.toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      lineTotal: lineTotalNum.toDouble(),
    );
  }
}
