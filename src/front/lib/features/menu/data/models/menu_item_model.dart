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
    required super.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      categoryId: json['category'], // Changed from 'categoryId' to 'category'
      title: json['title'],
      description: json['subtitle'], // Changed from 'description' to 'subtitle'
      price: (json['unitPrice'] as num).toDouble(), // Changed from 'price' to 'unitPrice'
      available: json['available'] ?? true, // Added default value
      rating: json['rating'] ?? 0.0, // Added default value
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': categoryId, // Changed from 'categoryId' to 'category'
      'title': title,
      'subtitle': description, // Changed from 'description' to 'subtitle'
      'unitPrice': price, // Changed from 'price' to 'unitPrice'
      'available': available,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}