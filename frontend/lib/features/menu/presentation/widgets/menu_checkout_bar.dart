import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class MenuCheckoutBar extends StatelessWidget {
  const MenuCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: .08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: colorScheme.primary),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                      '2 items in cart',
                      style: textTheme.labelLarge,
                    ),
                    SelectableText(
                      'Estimated 25 mins',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SelectableText('\$34.40', style: textTheme.headlineMedium),
              const SizedBox(width: AppDimensions.spacingMd),
              ElevatedButton(onPressed: () {}, child: const Text('Checkout')),
            ],
          ),
        ),
      ),
    );
  }
}
