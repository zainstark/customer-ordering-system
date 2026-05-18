import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/presentation/cubit/order_tracking_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/order_tracking_state.dart';
import 'package:frontend/features/orders/presentation/widgets/tracking_timeline.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderSummary,
  });

  final String orderId;
  final OrderItemEntity orderSummary;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderTrackingCubit>().loadTracking(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final order = widget.orderSummary;


    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        title: const Text('Track Your Order'),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          if (state.status == OrderTrackingStatus.loading ||
              state.status == OrderTrackingStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrderTrackingStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text('Failed to load tracking details.', style: textTheme.titleMedium),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(state.errorMessage!, style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                  ],
                  const SizedBox(height: AppDimensions.spacingLg),
                  FilledButton.tonal(
                    onPressed: () => context.read<OrderTrackingCubit>().loadTracking(widget.orderId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final tracking = state.tracking;
          if (tracking == null) {
            return const Center(child: Text('Tracking data not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Order #${_shortId(widget.orderId)}',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    if (tracking.currentStatus != 'delivered')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '~${tracking.estimatedTimeMinutes} min remaining',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Delivered',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Tracking Timeline (Stepper)
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXl),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: TrackingTimeline(
                        currentStatus: tracking.currentStatus,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),
                    
                    // History List
                    Text('Status History', style: textTheme.titleLarge),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tracking.history.length,
                        separatorBuilder: (_, __) => Divider(color: colorScheme.outlineVariant, height: 1),
                        itemBuilder: (context, index) {
                          // History is usually descending, so index 0 is most recent
                          final entry = tracking.history[index];
                          final stageLabel = entry.status[0].toUpperCase() + entry.status.substring(1);
                          return ListTile(
                            leading: Icon(Icons.history, color: colorScheme.primary),
                            title: Text(stageLabel, style: textTheme.titleMedium),
                            subtitle: Text(_formatTime(entry.timestamp), style: textTheme.bodyMedium),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Details Section
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 800;
                        if (isDesktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _OrderSummaryCard(order: order),
                              ),
                              const SizedBox(width: AppDimensions.spacingLg),
                              const Expanded(
                                flex: 1,
                                child: _SideActions(),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _OrderSummaryCard(order: order),
                            const SizedBox(height: AppDimensions.spacingLg),
                            const _SideActions(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8).toUpperCase();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderItemEntity order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Text(
              'Order Summary',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingMd),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$${(order.totalAmount - 3.99).clamp(0, double.infinity).toStringAsFixed(2)}', // Mock calculation
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Fee',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$3.99', // Mock delivery fee
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: AppDimensions.spacingMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideActions extends StatelessWidget {
  const _SideActions();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Live Map Placeholder
        Container(
          height: 256,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.map,
                  size: 64,
                  color: colorScheme.surfaceContainerHighest,
                ),
              ),
              Center(
                child: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  radius: 20,
                  child: Icon(
                    Icons.location_on,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              Positioned(
                bottom: AppDimensions.spacingMd,
                left: AppDimensions.spacingMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    'Live Tracking',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
