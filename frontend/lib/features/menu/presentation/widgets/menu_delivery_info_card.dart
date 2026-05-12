import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/menu/presentation/widgets/menu_surface_card.dart';

class MenuDeliveryInfoCard extends StatelessWidget {
  const MenuDeliveryInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MenuSurfaceCard(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: AppDimensions.iconXl,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              subtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
