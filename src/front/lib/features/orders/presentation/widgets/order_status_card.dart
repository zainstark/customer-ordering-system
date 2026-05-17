import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/domain/entities/order_item_entities.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_surface_card.dart';

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({super.key, required this.order});

  final OrderItemEntity order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OrdersSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: AppDimensions.iconLg,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Order #${_shortId(order.orderId)}',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    SelectableText(
                      '${_formatDate(order.placedAt)} • ${order.items.length} item(s)',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLg,
                  vertical: AppDimensions.paddingSm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                ),
                child: SelectableText(
                  order.status,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
            child: LinearProgressIndicator(
              value: order.progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          // Friendly item summary
          if (order.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
              child: SelectableText(
                _itemsSummary(order),
                style: textTheme.bodyMedium,
              ),
            ),
          Row(
            children: [
              SelectableText(
                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8).toUpperCase();
  }

  String _itemsSummary(OrderItemEntity order) {
    final items = order.items;
    if (items.isEmpty) return '';
    final first = items.first;
    if (items.length == 1) return '${first.title} x${first.quantity}';

    final rest = items.length - 1;
    return '${first.title} x${first.quantity} + $rest more';
  }
}
