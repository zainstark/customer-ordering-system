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
      menuItems: [
        MenuItemModel(
          id: 'd1',
          categoryId: 'burgers',
          title: 'The Royal Wagyu',
          description: 'Triple-stacked wagyu beef with creamy aioli.',
          price: 17.5,
          available: true,
          rating: 4.8,
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'pizza',
      label: 'Pizza',
      menuItems: [
        MenuItemModel(
          id: 'd2',
          categoryId: 'pizza',
          title: 'Buffalo Margherita',
          description: 'Classic Neapolitan crust with fresh basil.',
          price: 15.2,
          available: true,
          rating: 4.9,
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'sushi',
      label: 'Sushi',
      menuItems: [
        MenuItemModel(
          id: 'd3',
          categoryId: 'sushi',
          title: 'Omakase Platter',
          description: 'Chef-crafted seasonal pieces and rolls.',
          price: 21.0,
          available: true,
          rating: 4.7,
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'salads',
      label: 'Salads',
      menuItems: [
        MenuItemModel(
          id: 'd4',
          categoryId: 'salads',
          title: 'Zen Buddha Bowl',
          description: 'Quinoa, avocado, roasted sweet potato, and greens.',
          price: 12.9,
          available: true,
          rating: 4.6,
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
        ),
      ],
    ),
    const MenuCategoryModel(
      id: 'desserts',
      label: 'Desserts',
      menuItems: [
        MenuItemModel(
          id: 'd5',
          categoryId: 'desserts',
          title: 'Hazelnut Tiramisu',
          description: 'Creamy tiramisu with roasted hazelnut crunch.',
          price: 9.5,
          available: false,
          rating: 4.7,
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1673108852141-e8c3c22a4a22?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D',
        ),
      ],
    ),
  ];
}
