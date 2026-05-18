import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_item_widget.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_skeleton_item.dart';
import 'package:go_router/go_router.dart';

class NotificationPopup extends StatefulWidget {
  const NotificationPopup({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.topRight,
            child: Container(
              width: 360,
              height: 500,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                      vertical: AppDimensions.paddingSm,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        BlocBuilder<NotificationCubit, NotificationState>(
                          builder: (context, state) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingSm,
                                vertical: AppDimensions.paddingXs,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusChip),
                              ),
                              child: Text(
                                '${state.unreadCount} New',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Notifications list
                  Expanded(
                    child: BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (context, state) {
                        if (state.status == NotificationRequestStatus.loading &&
                            state.notifications.isEmpty) {
                          return ListView.separated(
                            itemCount: 5,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color:
                                  colorScheme.outlineVariant.withValues(alpha: 0.1),
                            ),
                            itemBuilder: (context, index) =>
                                const NotificationSkeletonItem(),
                          );
                        }

                        if (state.status == NotificationRequestStatus.empty ||
                            state.notifications.isEmpty) {
                          return NotificationEmptyState();
                        }

                        // Show only the first 5 notifications in the popup
                        final displayedNotifications = state.notifications.take(5).toList();

                        return ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                          ),
                          itemCount: displayedNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = displayedNotifications[index];
                            return NotificationItemWidget(
                              notification: notification,
                              onTap: () {
                                if (!notification.isRead) {
                                  context
                                      .read<NotificationCubit>()
                                      .markAsRead(notification.messageId);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Footer - Show All button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        widget.onClose();
                        context.push(RoutesPath.notifications);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingSm,
                        ),
                      ),
                      child: Text(
                        'Show All Notifications',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
