import 'dart:convert';

import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';

class CartItemModel extends CartItemEntity {
  CartItemModel({
    required super.id,
    required super.cartId,
    required super.menuItemId,
    required super.title,
    required super.subtitle,
    required super.unitPrice,
    required super.quantity,
    required super.imageUrl,
  });

  double get totalPrice => unitPrice * quantity;
  String get cartItemId => id;
  double get unitPriceSnapshot => unitPrice;
  double get lineTotal => totalPrice;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cartId': cartId,
      'menuItemId': menuItemId,
      'title': title,
      'subtitle': subtitle,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as String,
      cartId: map['cartId'] as String,
      menuItemId: map['menuItemId'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      imageUrl: map['imageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItemModel.fromJson(String source) =>
      CartItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  CartItemModel copyWith({
    String? id,
    String? cartId,
    String? menuItemId,
    String? title,
    String? subtitle,
    double? unitPrice,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      menuItemId: menuItemId ?? this.menuItemId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
