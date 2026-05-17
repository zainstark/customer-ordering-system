import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class NotificationSkeletonItem extends StatelessWidget {
  const NotificationSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar skeleton
          Container(
            width: AppDimensions.avatarSizeMd,
            height: AppDimensions.avatarSizeMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                // Message line 1
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                // Message line 2
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
