import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';
import 'package:frontend/features/menu/domain/repositories/menu_repository.dart';

class GetMenuCategoriesUseCase {
  const GetMenuCategoriesUseCase(this._menuRepository);

  final MenuRepository _menuRepository;

  Future<List<MenuCategoryEntity>> call() {
    return _menuRepository.getMenuCategories();
  }
}
