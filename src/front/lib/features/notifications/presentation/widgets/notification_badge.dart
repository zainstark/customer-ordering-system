import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is 0
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Format count: show up to 99, then 99+ for anything higher
    final displayCount = count > 99 ? '99+' : '$count';

    return Positioned(
      top: -4,
      right: -4,
      child: Container(
        width: AppDimensions.avatarSizeXs,
        height: AppDimensions.avatarSizeXs,
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.surfaceContainerLowest,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            displayCount,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onError,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
