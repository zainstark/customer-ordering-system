import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_surface_card.dart';
import 'package:frontend/features/widgets/app_network_image.dart';

class MenuFoodCard extends StatelessWidget {
  const MenuFoodCard({super.key, required this.item, required this.onTap});

  final MenuItemEntity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      onTap: onTap,
      child: MenuSurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: AppNetworkImage(
                imageUrl: item.imageUrl ?? 'https://via.placeholder.com/300',
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLg),
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
                        child: SelectableText(
                          item.title,
                          style: textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      SelectableText(
                        item.available ? 'available' : 'unavailable',
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  SelectableText(item.description ?? "No description available", style: textTheme.bodyMedium),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Row(
                    children: [
                      SelectableText(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
