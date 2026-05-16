import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';
import 'package:frontend/features/widgets/app_network_image.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.model,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemEntity model;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: AppNetworkImage(
              imageUrl: model.imageUrl,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(model.title, style: textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.spacingXs),
                SelectableText(model.subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: AppDimensions.spacingMd),
                SelectableText(
                  'cart_item_id: ${model.id} • menu_item_id: ${model.menuItemId}',
                  style: textTheme.labelSmall,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                SelectableText(
                  '\$${(model.unitPrice * model.quantity).toStringAsFixed(2)}',
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
                    SelectableText(
                      '${model.quantity}',
                      style: textTheme.labelLarge,
                    ),
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
