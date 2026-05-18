import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/menu/domain/entities/menu_category_entity.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_state.dart';
import 'package:frontend/features/menu/presentation/screens/menu_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockMenuCubit extends MockCubit<MenuState> implements MenuCubit {}

class _MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late _MockMenuCubit menuCubit;
  late _MockCartCubit cartCubit;

  const menuStateSuccess = MenuState(
    categories: [
      MenuCategoryEntity(
        id: 'burgers',
        label: 'Burgers',
        menuItems: [
          MenuItemEntity(
            id: 'dish_1',
            categoryId: 'burgers',
            title: 'Classic Burger',
            description: 'Grilled beef',
            price: 10.0,
            available: true,
            rating: 4.5,
            imageUrl: 'https://example.com/burger.jpg',
          ),
        ],
      ),
    ],
    selectedCategoryId: 'burgers',
    status: MenuRequestStatus.success,
  );

  setUp(() {
    menuCubit = _MockMenuCubit();
    cartCubit = _MockCartCubit();
    when(
      () => cartCubit.state,
    ).thenReturn(const CartState(accountId: 'acc_1', models: []));
  });

  Widget _wrapWithProviders(MenuState state) {
    when(() => menuCubit.state).thenReturn(state);
    whenListen(menuCubit, Stream<MenuState>.value(state), initialState: state);

    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuCubit>.value(value: menuCubit),
        BlocProvider<CartCubit>.value(value: cartCubit),
      ],
      child: const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(800, 1200)),
          child: Scaffold(body: MenuScreen()),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator while menu is loading', (tester) async {
    await tester.pumpWidget(
      _wrapWithProviders(
        const MenuState(
          categories: [],
          selectedCategoryId: '',
          status: MenuRequestStatus.loading,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message and retries on button tap', (tester) async {
    await tester.pumpWidget(
      _wrapWithProviders(
        const MenuState(
          categories: [],
          selectedCategoryId: '',
          status: MenuRequestStatus.error,
          errorMessage:
              'Unable to load the menu at this time. Please try again later.',
        ),
      ),
    );

    expect(
      find.textContaining(
        'Unable to load the menu at this time. Please try again later.',
      ),
      findsOneWidget,
    );
    final retryButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(retryButton.onPressed, isNotNull);
  });

  testWidgets(
    'shows auth-related message when error exposes session requirement',
    (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const MenuState(
            categories: [],
            selectedCategoryId: '',
            status: MenuRequestStatus.error,
            errorMessage: 'Please log in to browse the menu.',
          ),
        ),
      );

      expect(find.text('Please log in to browse the menu.'), findsOneWidget);
    },
  );

  testWidgets('shows empty-state message when success has no categories', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithProviders(
        const MenuState(
          categories: [],
          selectedCategoryId: '',
          status: MenuRequestStatus.success,
        ),
      ),
    );

    expect(find.text('No menu items are currently available.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('renders menu content when loading succeeds', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(menuStateSuccess));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Burgers'), findsWidgets);
    expect(find.text('Classic Burger'), findsOneWidget);
    expect(find.text('Popular picks in this category'), findsOneWidget);
  });
}
