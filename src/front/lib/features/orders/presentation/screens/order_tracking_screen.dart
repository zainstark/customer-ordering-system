import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';
import 'package:frontend/features/orders/presentation/widgets/tracking_timeline.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state.fetchStatus == FetchStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        OrderItemEntity? order;
        try {
          order = [...state.activeOrders, ...state.pastOrders]
              .firstWhere((o) => o.orderId == orderId);
        } catch (e) {
          order = null;
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Track Order')),
            body: const Center(child: Text('Order not found')),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
            title: const Text('Track Your Order'),
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${_shortId(order.orderId)}',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      'Estimated arrival: 25-30 mins',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Tracking Timeline
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXl),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXl),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: TrackingTimeline(currentStatus: order.status),
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
                                child: _OrderSummaryCard(order: order!),
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
                            _OrderSummaryCard(order: order!),
                            const SizedBox(height: AppDimensions.spacingLg),
                            const _SideActions(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Feedback Section
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingLg),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXl),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          return Flex(
                            direction:
                                isMobile ? Axis.vertical : Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        colorScheme.tertiaryContainer,
                                    radius: 24,
                                    child: Icon(
                                      Icons.stars,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.spacingLg),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rate your last experience?',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Earn 50 ZestyPoints for every review.',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isMobile)
                                const SizedBox(height: AppDimensions.spacingMd),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: const Text('Leave Review'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8).toUpperCase();
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
                      '\$${(order.totalAmount - 3.99).toStringAsFixed(2)}', // Mock calculation
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
        const SizedBox(height: AppDimensions.spacingLg),

        // Support Card
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Need Help?',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                'Our support team is available 24/7 for any questions regarding your order.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: const Text('Chat with Support'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
