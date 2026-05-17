import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/cart/presentation/widgets/app_surface_card.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/order_cubit.dart';

class CartOrderSummaryCard extends StatelessWidget {
  const CartOrderSummaryCard({super.key, required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) {
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
                final cubit = getIt<OrderCubit>();
                // Minimal address provided since UI does not collect address here
                const address = 'No address provided';
                await cubit.placeOrder(address: address);

                if (!context.mounted) return;

                if (cubit.state.status == OrderRequestStatus.success) {
                  // Immediately sync top-bar popup and badge after order placement.
                  context.read<NotificationCubit>().loadNotifications(isRefresh: true);
                  context.read<NotificationBadgeCubit>().loadUnreadCount();
                }

                // TODO: After successful order placement, navigate to the payment
                // screen and provide the same OrderCubit instance so the payment
                // implementation can access `state.order?.orderId`.
                // Example to implement later:
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) => BlocProvider.value(
                //       value: cubit,
                //       child: const PaymentScreen(), // implement this screen
                //     ),
                //   ),
                // );
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
