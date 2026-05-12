import 'package:flutter/material.dart';

class MenuItemEntity {
  const MenuItemEntity({
    required this.id,
    required this.categoryId,

    required this.title,
    required this.description,
    required this.price,
    required this.available,
    required this.rating,
    required this.icon,
  });

  final String id;
  final String categoryId;
  final String title;
  final String description;
  final double price;
  final bool available;
  final double rating;
  final IconData icon;
}
