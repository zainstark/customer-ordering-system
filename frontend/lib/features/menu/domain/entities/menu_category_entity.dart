import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';

class MenuCategoryEntity {
  const MenuCategoryEntity({
    required this.id,
    required this.label,
    required this.menuItems,
  });

  final String id;
  final String label;
  final List<MenuItemEntity> menuItems;
}
