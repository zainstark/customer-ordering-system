import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/menu/data/models/menu_category_model.dart';
import 'package:frontend/features/menu/data/models/menu_item_model.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit()
    : super(
        MenuState(
          categories: _dummyCategories,
          selectedCategoryId: _dummyCategories.first.id,
        ),
      );

  void selectCategory(String categoryId) {
    if (state.selectedCategoryId == categoryId) return;
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  static final List<MenuCategoryModel> _dummyCategories = [
    const MenuCategoryModel(
      id: 'burgers',
      label: 'Burgers',
      icon: Icons.lunch_dining_outlined,
      menuItems: [
        MenuItemModel(
          id: 'd1',
          categoryId: 'burgers',
          title: 'The Royal Wagyu',
          description: 'Triple-stacked wagyu beef with creamy aioli.',
          price: 17.5,
          available: true,
          rating: 4.8,
          icon: Icons.lunch_dining_outlined,
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'pizza',
      label: 'Pizza',
      icon: Icons.local_pizza_outlined,
      menuItems: [
        MenuItemModel(
          id: 'd2',
          categoryId: 'pizza',
          title: 'Buffalo Margherita',
          description: 'Classic Neapolitan crust with fresh basil.',
          price: 15.2,
          available: true,
          rating: 4.9,
          icon: Icons.local_pizza_outlined,
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'sushi',
      label: 'Sushi',
      icon: Icons.set_meal_outlined,
      menuItems: [
        MenuItemModel(
          id: 'd3',
          categoryId: 'sushi',
          title: 'Omakase Platter',
          description: 'Chef-crafted seasonal pieces and rolls.',
          price: 21.0,
          available: true,
          rating: 4.7,
          icon: Icons.set_meal_outlined,
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'salads',
      label: 'Salads',
      icon: Icons.eco_outlined,
      menuItems: [
        MenuItemModel(
          id: 'd4',
          categoryId: 'salads',
          title: 'Zen Buddha Bowl',
          description: 'Quinoa, avocado, roasted sweet potato, and greens.',
          price: 12.9,
          available: true,
          rating: 4.6,
          icon: Icons.ramen_dining_outlined,
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'desserts',
      label: 'Desserts',
      icon: Icons.icecream_outlined,
      menuItems: [
        MenuItemModel(
          id: 'd5',
          categoryId: 'desserts',
          title: 'Hazelnut Tiramisu',
          description: 'Creamy tiramisu with roasted hazelnut crunch.',
          price: 9.5,
          available: false,
          rating: 4.7,
          icon: Icons.cake_outlined,
        ),
      ],
    ),
  ];
}
