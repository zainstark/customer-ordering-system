import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/domain/entities/card_item_entity.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';
import 'package:frontend/features/widgets/app_network_image.dart';

class CheckoutItemTile extends StatelessWidget {
  const CheckoutItemTile({
    super.key,
    required this.item,
  });

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: AppNetworkImage(
              imageUrl: item.imageUrl,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(item.subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: AppDimensions.spacingXs),
                Text('Qty: ${item.quantity}', style: textTheme.labelLarge),
              ],
            ),
          ),
          Text(
            '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
            style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
