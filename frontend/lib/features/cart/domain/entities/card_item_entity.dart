import 'package:flutter/material.dart';

class CartItemEntity {
  const CartItemEntity({
    required this.id,
    required this.cartId,
    required this.menuItemId,
    required this.title,
    required this.subtitle,
    required this.unitPrice,
    required this.quantity,
    required this.icon,
  });

  final String id;
  final String cartId;
  final String menuItemId;
  final String title;
  final String subtitle;
  final double unitPrice;
  final int quantity;
  final IconData icon;
}
