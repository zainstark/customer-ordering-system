import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_surface_card.dart';

class CartDeliveryAddressCard extends StatelessWidget {
  const CartDeliveryAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CartSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: colorScheme.primary),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Text(
                  'Delivery Address\n123 Culinary Drive, Foodie Square',
                  style: textTheme.bodyLarge,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Center(
              child: Icon(
                Icons.map_outlined,
                size: AppDimensions.iconXxl,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
