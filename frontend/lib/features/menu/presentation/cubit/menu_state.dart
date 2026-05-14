import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';

enum MenuRequestStatus { initial, loading, success, error }

class MenuState {
  const MenuState({
    required this.categories,
    required this.selectedCategoryId,
    this.status = MenuRequestStatus.initial,
    this.errorMessage,
  });

  final List<MenuCategoryEntity> categories;
  final String selectedCategoryId;
  final MenuRequestStatus status;
  final String? errorMessage;

  MenuCategoryEntity? get selectedCategory {
    if (selectedCategoryId.isEmpty || categories.isEmpty) return null;
    for (final category in categories) {
      if (category.id == selectedCategoryId) return category;
    }
    return null;
  }

  List<MenuItemEntity> get filteredDishes => selectedCategory?.menuItems ?? [];

  MenuState copyWith({
    List<MenuCategoryEntity>? categories,
    String? selectedCategoryId,
    MenuRequestStatus? status,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearErrorMessage = false,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? ''
          : selectedCategoryId ?? this.selectedCategoryId,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
