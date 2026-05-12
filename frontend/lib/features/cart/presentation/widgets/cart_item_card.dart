import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/data/models/cart_item_model.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.model,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel model;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              model.icon,
              size: AppDimensions.iconLg,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.title, style: textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(model.subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'cart_item_id: ${model.cartItemId} • menu_item_id: ${model.menuItemId}',
                  style: textTheme.labelSmall,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  '\$${model.lineTotal.toStringAsFixed(2)}',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingSm,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: onDecrement,
                      child: Icon(
                        Icons.remove,
                        size: AppDimensions.iconSm,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Text('${model.quantity}', style: textTheme.labelLarge),
                    const SizedBox(width: AppDimensions.spacingMd),
                    InkWell(
                      onTap: onIncrement,
                      child: Icon(
                        Icons.add,
                        size: AppDimensions.iconSm,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
