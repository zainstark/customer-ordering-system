import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_item_widget.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_skeleton_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load notifications when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<NotificationCubit>().loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    String _formatDateLabel(DateTime date) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d = DateTime(date.year, date.month, date.day);
      final diff = today.difference(d).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    List<MapEntry<String, List<NotificationEntity>>> _groupByDate(
        List<NotificationEntity> notifications) {
      final Map<DateTime, List<NotificationEntity>> tmp = {};
      for (final n in notifications) {
        final created = n.createdAt ?? DateTime.now();
        final key = DateTime(created.year, created.month, created.day);
        tmp.putIfAbsent(key, () => []).add(n);
      }

      final entries = tmp.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)); // newest first

      return entries
          .map((e) => MapEntry(_formatDateLabel(e.key), e.value))
          .toList();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        title: Text(
          'Notifications',
          style: textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unreadCount = state.notifications
                  .where((n) =>
                      n.deliveryStatus == NotificationDeliveryStatus.pending)
                  .length;

              if (unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  context.read<NotificationCubit>().markAllAsRead();
                },
                child: Text(
                  'Mark all as read',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppDimensions.paddingMd),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Content
              if (state.status == NotificationRequestStatus.loading &&
                  state.notifications.isEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const NotificationSkeletonItem(),
                    childCount: 8,
                  ),
                )
              else if (state.status == NotificationRequestStatus.empty ||
                  state.notifications.isEmpty)
                SliverFillRemaining(
                  child: NotificationEmptyState(),
                )
              else
                // Group notifications by date and render centered
                ..._groupByDate(state.notifications).expand((group) sync* {
                  // Header
                  yield SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingMd,
                            horizontal: AppDimensions.paddingMd,
                          ),
                          child: Text(
                            group.key,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                  // Items
                  yield SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = group.value[index];

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: NotificationItemWidget(
                              notification: notification,
                              onTap: () {
                                if (notification.deliveryStatus ==
                                    NotificationDeliveryStatus.pending) {
                                  context
                                      .read<NotificationCubit>()
                                      .markAsRead(notification.messageId);
                                }
                              },
                            ),
                          ),
                        );
                      },
                      childCount: group.value.length,
                    ),
                  );
                }).toList(),
              // Loading indicator at the end
              if (state.status == NotificationRequestStatus.loading &&
                  state.notifications.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingXl,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
