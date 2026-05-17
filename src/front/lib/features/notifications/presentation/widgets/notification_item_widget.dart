import 'package:flutter/material.dart';
import 'package:frontend/Core/theme/app_colors.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  /// Get the appropriate icon based on delivery channel
  (IconData, Color) _getChannelIconAndColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine icon based on order_id or delivery channel characteristics
    if (notification.orderId != null) {
      // Order-related notification
      return (Icons.local_shipping, colorScheme.primary.withValues(alpha: 0.12));
    }

    // Generic in-app notification
    return (Icons.info, colorScheme.secondary.withValues(alpha: 0.12));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (typeIcon, bgColor) = _getChannelIconAndColor(context);
    final isUnread = notification.deliveryStatus == NotificationDeliveryStatus.pending;

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingSm,
          ),
          decoration: BoxDecoration(
            color: isUnread
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerLowest,
            border: Border(
              left: BorderSide(
                color: isUnread ? colorScheme.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Avatar
              Container(
                width: AppDimensions.avatarSizeMd,
                height: AppDimensions.avatarSizeMd,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    typeIcon,
                    size: AppDimensions.iconMd,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject and timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.subject,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    // Body (message)
                    Text(
                      notification.body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Unread indicator
              if (isUnread) ...[
                const SizedBox(width: AppDimensions.spacingSm),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Format timestamp to relative time string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'On ${_formatDate(timestamp)}';
    }
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
