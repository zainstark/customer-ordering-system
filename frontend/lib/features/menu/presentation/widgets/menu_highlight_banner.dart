import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class MenuHighlightBanner extends StatelessWidget {
  const MenuHighlightBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
              vertical: AppDimensions.paddingXs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
            ),
            child: Text('LIMITED OFFER', style: textTheme.labelSmall),
          ),
          const Spacer(),
          Text(
            '50% off your first order',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Use code START50 at checkout',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: .8),
            ),
          ),
        ],
      ),
    );
  }
}
