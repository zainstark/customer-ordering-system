
import 'package:flutter/material.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';

class MenuCategoryEntity {
  const MenuCategoryEntity({
    required this.id,
    required this.label,
    required this.icon,
    required this.menuItems,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<MenuItemEntity> menuItems;
}
