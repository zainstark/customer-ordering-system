import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';

abstract class MenuRepository {
  Future<List<MenuCategoryEntity>> getMenuCategories();
}
