import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_surface_card.dart';

class MenuFoodCard extends StatelessWidget {
  const MenuFoodCard({
    super.key,
    required this.menuItemId,
    required this.title,
    required this.description,
    required this.price,
    required this.available,
    required this.rating,
    required this.icon,
  });

  final String menuItemId;
  final String title;
  final String description;
  final double price;
  final bool available;
  final double rating;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MenuSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLg),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: AppDimensions.iconXl,
                color: colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: textTheme.headlineMedium),
                    ),
                    const Icon(Icons.star, size: AppDimensions.iconSm),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      rating.toStringAsFixed(1),
                      style: textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
                // const SizedBox(height: AppDimensions.spacingSm),
                // Text(
                //   'menu_item_id: $menuItemId • catalog_id: $catalogId',
                //   style: textTheme.labelSmall,
                // ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSm,
                        vertical: AppDimensions.paddingXs,
                      ),
                      decoration: BoxDecoration(
                        color: available
                            ? colorScheme.primaryContainer.withValues(alpha: .2)
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMax,
                        ),
                      ),
                      child: Text(
                        available ? 'available' : 'unavailable',
                        style: textTheme.labelSmall?.copyWith(
                          color: available
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
