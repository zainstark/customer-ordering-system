import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.state, required this.button});

  final state;
  final bool button;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Order summary', style: textTheme.headlineMedium),
          const SizedBox(height: AppDimensions.spacingSm),
          // SelectableText(
          //   'account_id: ${state.accountId}',
          //   style: textTheme.labelSmall,
          // ),
          const SizedBox(height: AppDimensions.spacingXl),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${state.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _SummaryRow(
            label: 'Delivery fee',
            value: '\$${state.deliveryFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _SummaryRow(
            label: 'Taxes',
            value: '\$${state.taxes.toStringAsFixed(2)}',
          ),
          const Divider(height: AppDimensions.spacingXxxl),
          _SummaryRow(
            label: 'Total',
            value: '\$${state.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          // const SizedBox(height: AppDimensions.spacingXl),
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(AppDimensions.paddingMd),
          //   decoration: BoxDecoration(
          //     color: colorScheme.surfaceContainerHigh,
          //     borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          //   ),
            // child: Row(
            //   children: [
            //     const Icon(Icons.credit_card_outlined),
            //     const SizedBox(width: AppDimensions.spacingMd),
            //     Expanded(
            //       child: SelectableText(
            //         'Visa •••• 4242',
            //         style: textTheme.bodyLarge,
            //       ),
            //     ),
            //     const Icon(Icons.chevron_right),
            //   ],
            // ),
          // ),
          // const SizedBox(height: AppDimensions.spacingXl),
          const SizedBox(height: AppDimensions.spacingXl),
          if (button)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(RoutesPath.checkout),
              child: const Text('Proceed to checkout'),
            ),
          ),
          // Center(
          //   child: SelectableText(
          //     'Estimated delivery: 25–35 mins',
          //     style: textTheme.bodyMedium,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SelectableText(
          label,
          style: isTotal ? textTheme.headlineMedium : textTheme.bodyLarge,
        ),
        const Spacer(),
        SelectableText(
          value,
          style: (isTotal ? textTheme.headlineLarge : textTheme.bodyLarge)
              ?.copyWith(color: isTotal ? colorScheme.primary : null),
        ),
      ],
    );
  }
}
