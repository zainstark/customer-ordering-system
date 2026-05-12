import 'package:frontend/features/menu/data/models/menu_category_model.dart';
import 'package:frontend/features/menu/data/models/menu_item_model.dart';

class MenuState {
  const MenuState({required this.categories, required this.selectedCategoryId});

  final List<MenuCategoryModel> categories;
  final String selectedCategoryId;

  MenuCategoryModel get selectedCategory =>
      categories.firstWhere((category) => category.id == selectedCategoryId);

  List<MenuItemModel> get filteredDishes =>
      selectedCategory.menuItems.cast<MenuItemModel>().toList();

  MenuState copyWith({
    List<MenuCategoryModel>? categories,
    String? selectedCategoryId,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}
