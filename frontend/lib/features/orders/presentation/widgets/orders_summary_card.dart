import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_surface_card.dart';

class OrdersSummaryCard extends StatelessWidget {
  const OrdersSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OrdersSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Quick summary', style: textTheme.headlineMedium),
          const SizedBox(height: AppDimensions.spacingXl),
          _SummaryLine(label: 'Orders this month', value: '12'),
          const SizedBox(height: AppDimensions.spacingMd),
          _SummaryLine(label: 'Total spent', value: '\$342.50'),
          const SizedBox(height: AppDimensions.spacingMd),
          _SummaryLine(label: 'Points earned', value: '850'),
          const SizedBox(height: AppDimensions.spacingXl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: SelectableText(
                    'You have a reward! Get \$5 off your next order.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: SelectableText(
                    'You have a reward! Get \$5 off your next order.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SelectableText(label, style: textTheme.bodyLarge),
        const Spacer(),
        SelectableText(
          value,
          style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }
}
