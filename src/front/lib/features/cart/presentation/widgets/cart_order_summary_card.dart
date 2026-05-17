import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';
import 'package:frontend/features/orders/presentation/cubit/order_cubit.dart';

class CartOrderSummaryCard extends StatelessWidget {
  const CartOrderSummaryCard({super.key, required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Order summary', style: textTheme.headlineMedium),
          const SizedBox(height: AppDimensions.spacingSm),
          SelectableText(
            'account_id: ${state.accountId}',
            style: textTheme.labelSmall,
          ),
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
          const SizedBox(height: AppDimensions.spacingXl),
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(AppDimensions.paddingMd),
          //   decoration: BoxDecoration(
          //     color: colorScheme.surfaceContainerHigh,
          //     borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          //   ),
          //   child: Row(
          //     children: [
          //       const Icon(Icons.credit_card_outlined),
          //       const SizedBox(width: AppDimensions.spacingMd),
          //       Expanded(
          //         child: SelectableText(
          //           'Visa •••• 4242',
          //           style: textTheme.bodyLarge,
          //         ),
          //       ),
          //       const Icon(Icons.chevron_right),
          //     ],
          //   ),
          // ),
          const SizedBox(height: AppDimensions.spacingXl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // create an OrderCubit instance and place the order
                final orderCubit = getIt<OrderCubit>();
                const address = 'No address provided';

                await orderCubit.placeOrder(address: address);

                // If order placed successfully, refresh cart and navigate to payment
                if (orderCubit.state.status == OrderRequestStatus.success &&
                    orderCubit.state.order != null) {
                  // refresh the current cart (backend clears cart on success)
                  try {
                    context.read<CartCubit>().loadCart();
                  } catch (_) {
                    // ignore if cart cubit not provided in this context
                  }

                  // Navigate to payment screen and provide the OrderCubit instance.
                  // BlocProvider will take ownership and close the cubit when disposed.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider<OrderCubit>(
                        create: (_) => orderCubit,
                        child: const PaymentScreen(),
                      ),
                    ),
                  );
                } else {
                  // show error
                  final message = orderCubit.state.errorMessage ?? 'Failed to place order.';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              child: const Text('Proceed to checkout'),
            ),
          ),
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
