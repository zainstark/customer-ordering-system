import 'dart:convert';

import 'package:flutter/material.dart';
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
    required super.icon,
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
      'icon': icon.codePoint,
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
      quantity: map['quantity'] as int,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
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
    IconData? icon,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      menuItemId: menuItemId ?? this.menuItemId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      icon: icon ?? this.icon,
    );
  }
}
