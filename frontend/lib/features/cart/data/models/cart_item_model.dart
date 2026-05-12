
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
