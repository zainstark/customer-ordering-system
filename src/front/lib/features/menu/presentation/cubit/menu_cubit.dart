import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/menu/domain/usecases/get_menu_categories_usecase.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit(GetMenuCategoriesUseCase getMenuCategoriesUseCase)
    : _getMenuCategoriesUseCase = getMenuCategoriesUseCase,
      super(const MenuState(categories: [], selectedCategoryId: ''));

  final GetMenuCategoriesUseCase _getMenuCategoriesUseCase;

  Future<void> loadMenu() async {
    emit(
      state.copyWith(
        status: MenuRequestStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final categories = await _getMenuCategoriesUseCase();
      final selectedId = categories.isEmpty ? '' : categories.first.id;

      emit(
        state.copyWith(
          categories: categories,
          selectedCategoryId: selectedId,
          status: MenuRequestStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MenuRequestStatus.error,
          errorMessage: error.toString(),
          clearSelectedCategory: true,
        ),
      );
    }
  }

  void selectCategory(String categoryId) {
    if (state.selectedCategoryId == categoryId) return;
    emit(state.copyWith(selectedCategoryId: categoryId));
  }
}
