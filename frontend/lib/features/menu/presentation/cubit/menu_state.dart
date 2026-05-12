import 'package:frontend/features/menu/data/models/menu_category_model.dart';
import 'package:frontend/features/menu/data/models/menu_item_model.dart';

class MenuState {
  const MenuState({
    required this.categories,
    required this.dishes,
    required this.selectedCategoryId,
  });

  final List<MenuCategoryModel> categories;
  final List<MenuItemModel> dishes;
  final String selectedCategoryId;

  List<MenuItemModel> get filteredDishes =>
      dishes.where((dish) => dish.categoryId == selectedCategoryId).toList();

  MenuState copyWith({
    List<MenuCategoryModel>? categories,
    List<MenuItemModel>? dishes,
    String? selectedCategoryId,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      dishes: dishes ?? this.dishes,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}
