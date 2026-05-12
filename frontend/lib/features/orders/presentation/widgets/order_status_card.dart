import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/data/models/order_item_model.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_surface_card.dart';

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({super.key, required this.order});

  final OrderItemModel order;

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
                    Text(order.orderId, style: textTheme.headlineMedium),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      'account_id: ${order.accountId} • placed_at: ${_formatDate(order.placedAt)}',
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
                child: Text(
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
          Row(
            children: [
              Text(
                'total_amount: \$${order.totalAmount.toStringAsFixed(2)}',
                style: textTheme.bodyLarge,
              ),
              const Spacer(),
              OutlinedButton(onPressed: () {}, child: const Text('Support')),
              const SizedBox(width: AppDimensions.spacingSm),
              ElevatedButton(onPressed: () {}, child: const Text('Track')),
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
}
