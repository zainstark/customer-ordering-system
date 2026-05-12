
import 'package:flutter/material.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.description,
    required super.price,
    required super.available,
    required super.rating,
    required super.icon, 
  });

    factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      available: json['available'],
      rating: (json['rating'] as num).toDouble(),
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'available': available,
      'rating': rating,
      'icon': icon.codePoint,
    };
  }

}
