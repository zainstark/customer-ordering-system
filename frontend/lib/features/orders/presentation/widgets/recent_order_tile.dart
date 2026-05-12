import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_surface_card.dart';

class RecentOrderTile extends StatelessWidget {
  const RecentOrderTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OrdersSurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: AppDimensions.avatarSizeMd / 2,
            backgroundColor: colorScheme.surfaceContainerHigh,
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(subtitle, style: textTheme.bodyMedium),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Reorder')),
        ],
      ),
    );
  }
}
