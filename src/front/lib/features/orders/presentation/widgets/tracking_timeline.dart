import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

enum OrderTrackingStage {
  pending('Pending', Icons.pending_actions),
  confirmed('Confirmed', Icons.check_circle),
  preparing('Preparing', Icons.soup_kitchen),
  ready('Ready', Icons.restaurant),
  delivery('Delivery', Icons.delivery_dining),
  delivered('Delivered', Icons.home);

  const OrderTrackingStage(this.label, this.icon);
  final String label;
  final IconData icon;
}

class TrackingTimeline extends StatelessWidget {
  const TrackingTimeline({super.key, required this.currentStatus});

  final String currentStatus;

  OrderTrackingStage _getStage() {
    final statusMap = {
      'pending': OrderTrackingStage.pending,
      'confirmed': OrderTrackingStage.confirmed,
      'preparing': OrderTrackingStage.preparing,
      'ready': OrderTrackingStage.ready,
      'delivery': OrderTrackingStage.delivery,
      'delivered': OrderTrackingStage.delivered,
    };
    return statusMap[currentStatus] ?? OrderTrackingStage.pending;
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = _getStage();
    final stages = OrderTrackingStage.values;
    final currentIndex = stages.indexOf(currentStage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Stack(
          children: [
            // Background line (Desktop only)
            if (!isMobile)
              Positioned(
                top: 24,
                left: 32,
                right: 32,
                child: Container(
                  height: 4,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            // Foreground line (Desktop only)
            if (!isMobile)
              Positioned(
                top: 24,
                left: 32,
                // Roughly calculate the width based on progress
                width: constraints.maxWidth *
                    (currentIndex / (stages.length - 1 == 0 ? 1 : stages.length - 1)) *
                    0.8,
                child: Container(
                  height: 4,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: stages.map((stage) {
                final index = stages.indexOf(stage);
                final isCompleted = index < currentIndex;
                final isActive = index == currentIndex;
                final isFuture = index > currentIndex;

                return _TimelineStep(
                  stage: stage,
                  isCompleted: isCompleted,
                  isActive: isActive,
                  isFuture: isFuture,
                  isMobile: isMobile,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.stage,
    required this.isCompleted,
    required this.isActive,
    required this.isFuture,
    required this.isMobile,
  });

  final OrderTrackingStage stage;
  final bool isCompleted;
  final bool isActive;
  final bool isFuture;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bgColor = isActive
        ? colorScheme.primaryContainer
        : isCompleted
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest;

    final iconColor = isActive || isCompleted
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    final iconSize = isActive ? 32.0 : 24.0;
    final boxSize = isActive ? 56.0 : 48.0;

    return Opacity(
      opacity: isFuture ? 0.4 : 1.0,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: isMobile ? AppDimensions.spacingMd : 0),
        child: Flex(
          direction: isMobile ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: colorScheme.primaryContainer.withValues(alpha: .4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                stage.icon,
                color: iconColor,
                size: iconSize,
              ),
            ),
            SizedBox(
              height: isMobile ? 0 : AppDimensions.spacingSm,
              width: isMobile ? AppDimensions.spacingMd : 0,
            ),
            Column(
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  stage.label,
                  style: isActive
                      ? textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        )
                      : textTheme.labelLarge?.copyWith(
                          color: isCompleted
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                ),
                if (isActive)
                  Text(
                    'In Progress',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
