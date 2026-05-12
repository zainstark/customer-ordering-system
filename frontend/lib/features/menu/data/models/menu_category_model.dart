import 'package:flutter/material.dart';
import 'package:frontend/features/menu/data/models/menu_item_model.dart';
import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';

class MenuCategoryModel extends MenuCategoryEntity {
  const MenuCategoryModel({
    required super.id,
    required super.label,
    required super.icon,
    required super.menuItems,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'],
      label: json['label'],
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      menuItems: (json['menuItems'] as List)
          .map((item) => MenuItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon.codePoint,
      'menuItems': menuItems.map((item) {
        if (item is MenuItemModel) {
          return (item).toJson();
        }
        throw Exception('Cannot serialize non-model MenuItem');
      }).toList(),
    };
  }
}
