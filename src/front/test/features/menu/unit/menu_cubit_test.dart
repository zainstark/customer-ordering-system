import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';
import 'package:frontend/features/menu/domain/usecases/get_menu_categories_usecase.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetMenuCategoriesUseCase extends Mock
    implements GetMenuCategoriesUseCase {}

void main() {
  late _MockGetMenuCategoriesUseCase getMenuCategoriesUseCase;
  late MenuCubit cubit;

  const burgers = MenuCategoryEntity(
    id: 'burgers',
    label: 'Burgers',
    menuItems: [
      MenuItemEntity(
        id: 'm1',
        categoryId: 'burgers',
        title: 'Classic Burger',
        description: 'Beef burger',
        price: 9.5,
        available: true,
        rating: 4.6,
        imageUrl: null,
      ),
    ],
  );
  const drinks = MenuCategoryEntity(
    id: 'drinks',
    label: 'Drinks',
    menuItems: [
      MenuItemEntity(
        id: 'm2',
        categoryId: 'drinks',
        title: 'Lemonade',
        description: 'Fresh',
        price: 2.5,
        available: true,
        rating: 4.1,
        imageUrl: null,
      ),
    ],
  );

  setUp(() {
    getMenuCategoriesUseCase = _MockGetMenuCategoriesUseCase();
    cubit = MenuCubit(getMenuCategoriesUseCase);
  });

  tearDown(() => cubit.close());

  test(
    'MenuState selectedCategory and filteredDishes use selectedCategoryId',
    () {
      const state = MenuState(
        categories: [burgers, drinks],
        selectedCategoryId: 'drinks',
        status: MenuRequestStatus.success,
      );

      expect(state.selectedCategory?.id, 'drinks');
      expect(state.filteredDishes.map((dish) => dish.id), ['m2']);
    },
  );

  test(
    'MenuState returns empty dishes when selected category does not exist',
    () {
      const state = MenuState(
        categories: [burgers],
        selectedCategoryId: 'unknown',
        status: MenuRequestStatus.success,
      );

      expect(state.selectedCategory, isNull);
      expect(state.filteredDishes, isEmpty);
    },
  );

  blocTest<MenuCubit, MenuState>(
    'loadMenu emits loading then success and selects first category',
    build: () {
      when(
        () => getMenuCategoriesUseCase(),
      ).thenAnswer((_) async => const [burgers, drinks]);
      return cubit;
    },
    act: (cubit) => cubit.loadMenu(),
    expect: () => [
      const TypeMatcher<MenuState>()
          .having((state) => state.status, 'status', MenuRequestStatus.loading)
          .having((state) => state.errorMessage, 'errorMessage', isNull),
      const TypeMatcher<MenuState>()
          .having((state) => state.status, 'status', MenuRequestStatus.success)
          .having(
            (state) => state.selectedCategoryId,
            'selectedCategoryId',
            'burgers',
          )
          .having((state) => state.categories.length, 'categories', 2)
          .having((state) => state.filteredDishes.length, 'filteredDishes', 1),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'loadMenu emits loading then error on failure and clears selected category',
    build: () {
      when(() => getMenuCategoriesUseCase()).thenThrow(
        Exception(
          'Unable to load the menu at this time. Please try again later.',
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.loadMenu(),
    expect: () => [
      const TypeMatcher<MenuState>().having(
        (state) => state.status,
        'status',
        MenuRequestStatus.loading,
      ),
      const TypeMatcher<MenuState>()
          .having((state) => state.status, 'status', MenuRequestStatus.error)
          .having((state) => state.selectedCategoryId, 'selectedCategoryId', '')
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('Unable to load the menu at this time'),
          ),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'loadMenu handles empty menu with success state and empty selected category',
    build: () {
      when(() => getMenuCategoriesUseCase()).thenAnswer((_) async => const []);
      return cubit;
    },
    act: (cubit) => cubit.loadMenu(),
    expect: () => [
      const TypeMatcher<MenuState>().having(
        (state) => state.status,
        'status',
        MenuRequestStatus.loading,
      ),
      const TypeMatcher<MenuState>()
          .having((state) => state.status, 'status', MenuRequestStatus.success)
          .having((state) => state.categories, 'categories', isEmpty)
          .having(
            (state) => state.selectedCategoryId,
            'selectedCategoryId',
            '',
          ),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'selectCategory updates selectedCategoryId when category differs',
    seed: () => const MenuState(
      categories: [burgers, drinks],
      selectedCategoryId: 'burgers',
      status: MenuRequestStatus.success,
    ),
    build: () => cubit,
    act: (cubit) => cubit.selectCategory('drinks'),
    expect: () => [
      const TypeMatcher<MenuState>()
          .having(
            (state) => state.selectedCategoryId,
            'selectedCategoryId',
            'drinks',
          )
          .having(
            (state) => state.filteredDishes.first.id,
            'firstDishId',
            'm2',
          ),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'selectCategory does not emit when selecting currently selected category',
    seed: () => const MenuState(
      categories: [burgers, drinks],
      selectedCategoryId: 'burgers',
      status: MenuRequestStatus.success,
    ),
    build: () => cubit,
    act: (cubit) => cubit.selectCategory('burgers'),
    expect: () => <MenuState>[],
  );
}
