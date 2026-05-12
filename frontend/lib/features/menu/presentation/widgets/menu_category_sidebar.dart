import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/menu/data/models/menu_category_model.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_surface_card.dart';

class MenuCategorySidebar extends StatelessWidget {
  const MenuCategorySidebar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<MenuCategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MenuSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Categories', style: textTheme.headlineSmall),
          const SizedBox(height: AppDimensions.spacingXs),
          SelectableText('Browse our kitchen', style: textTheme.bodyMedium),
          const SizedBox(height: AppDimensions.spacingXl),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
              child: _MenuCategoryTile(
                category: category,
                isSelected: selectedCategoryId == category.id,
                onTap: () => onCategorySelected(category.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MenuCategoryTile extends StatelessWidget {
  const _MenuCategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final MenuCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppDimensions.spacingMd),
            Text(
              category.label,
              style: textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${category.menuItems.length}',
              style: textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary.withValues(alpha: .8)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
