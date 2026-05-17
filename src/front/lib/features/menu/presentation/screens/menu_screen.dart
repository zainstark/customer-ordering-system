import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_state.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_category_sidebar.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_checkout_bar.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_delivery_info_card.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_item_details_sheet.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_food_card.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_highlight_banner.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_section_header.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    final isTabletUp = MediaQuery.sizeOf(context).width >= 760;

    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state.status == MenuRequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == MenuRequestStatus.error) {
          return _ErrorStateView(
            message:
                state.errorMessage ??
                'Something went wrong while loading menu.',
            onRetry: () => context.read<MenuCubit>().loadMenu(),
          );
        }

        if (state.status == MenuRequestStatus.success &&
            state.categories.isEmpty) {
          return _ErrorStateView(
            message: 'No menu items are currently available.',
            onRetry: () => context.read<MenuCubit>().loadMenu(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                SizedBox(
                  width: 280,
                  child: MenuCategorySidebar(
                    categories: state.categories,
                    selectedCategoryId: state.selectedCategoryId,
                    onCategorySelected: context
                        .read<MenuCubit>()
                        .selectCategory,
                  ),
                ),
              if (isDesktop) const SizedBox(width: AppDimensions.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDesktop) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: state.categories.map((category) {
                            final selected =
                                category.id == state.selectedCategoryId;
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppDimensions.spacingSm,
                              ),
                              child: ChoiceChip(
                                label: Text(category.label),
                                selected: selected,
                                onSelected: (_) => context
                                    .read<MenuCubit>()
                                    .selectCategory(category.id),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],
                    if (isTabletUp)
                      const Row(
                        children: [
                          Expanded(flex: 3, child: MenuHighlightBanner()),
                          SizedBox(width: AppDimensions.spacingLg),
                          Expanded(
                            child: MenuDeliveryInfoCard(
                              title: 'Fastest delivery in town',
                              subtitle: 'Average delivery time: 22 mins',
                            ),
                          ),
                        ],
                      )
                    else ...[
                      const MenuHighlightBanner(),
                      const SizedBox(height: AppDimensions.spacingLg),
                      const MenuDeliveryInfoCard(
                        title: 'Fastest delivery in town',
                        subtitle: 'Average delivery time: 22 mins',
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingXxl),
                    MenuSectionHeader(
                      title: _selectedCategoryLabel(state),
                      subtitle: 'Popular picks in this category',
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    GridView.builder(
                      itemCount: state.filteredDishes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : (isTabletUp ? 2 : 1),
                        crossAxisSpacing: AppDimensions.spacingLg,
                        mainAxisSpacing: AppDimensions.spacingLg,
                        childAspectRatio: isDesktop ? 1 : 1.15,
                      ),
                      itemBuilder: (context, index) {
                        final dish = state.filteredDishes[index];
                        return MenuFoodCard(
                          item: dish,
                          onTap: () {
                            final cartCubit = context.read<CartCubit>();
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => MenuItemDetailsSheet(
                                item: dish,
                                onAddToCart: (quantity) => cartCubit.addItem(
                                  menuItemId: dish.id,
                                  quantity: quantity,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    if (!isDesktop) ...[
                      const SizedBox(height: AppDimensions.spacingXl),
                      const MenuCheckoutBar(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _selectedCategoryLabel(MenuState state) {
    for (final category in state.categories) {
      if (category.id == state.selectedCategoryId) return category.label;
    }
    return 'Popular';
  }
}

class _ErrorStateView extends StatelessWidget {
  const _ErrorStateView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: AppDimensions.spacingMd),
            SelectableText(message, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spacingMd),
            ElevatedButton(
              onPressed: onRetry,
              child: const SelectableText('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
