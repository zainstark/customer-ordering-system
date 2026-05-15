import 'package:frontend/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';
import 'package:frontend/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._menuRemoteDataSource);

  final MenuRemoteDataSource _menuRemoteDataSource;

  @override
  Future<List<MenuCategoryEntity>> getMenuCategories() {
    return _menuRemoteDataSource.getMenuCategories();
  }
}
