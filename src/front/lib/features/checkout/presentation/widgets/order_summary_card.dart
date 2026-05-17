import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.state,
  });

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order summary', style: textTheme.headlineMedium),
          const SizedBox(height: AppDimensions.spacingMd),
          _summaryRow('Subtotal', '\$${state.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: AppDimensions.spacingMd),
          _summaryRow('Delivery fee', '\$${state.deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: AppDimensions.spacingMd),
          _summaryRow('Tax', '\$${state.taxes.toStringAsFixed(2)}'),
          const Divider(height: AppDimensions.spacingXxxl),
          _summaryRow(
            'Total',
            '\$${state.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          // const SizedBox(height: AppDimensions.spacingLg),
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(AppDimensions.paddingMd),
          //   decoration: BoxDecoration(
          //     color: colorScheme.surfaceContainerHigh,
          //     borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          //   ),
          //   child: Text(
          //     state.selectedMethod.label,
          //     style: textTheme.bodyLarge,
          //   ),
          // ),
          // const SizedBox(height: AppDimensions.spacingLg),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: null,
          //     child: const Text('Proceed to payment'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: isTotal
              ? const TextStyle(fontWeight: FontWeight.w700)
              : const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: isTotal
              ? const TextStyle(fontWeight: FontWeight.w700)
              : const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
