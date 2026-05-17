import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CheckoutCubit>().state;
    final cartState = context.watch<CartCubit>().state;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppDimensions.spacingXxxl),
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'Payment successful',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            state.paymentMessage ?? 'Your order has been placed successfully.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          _InfoTile(label: 'Order number', value: state.orderId ?? '—'),
          const SizedBox(height: AppDimensions.spacingMd),
          _InfoTile(label: 'Reference', value: state.orderReference ?? '—'),
          const SizedBox(height: AppDimensions.spacingMd),
          _InfoTile(label: 'Total paid', value: '\$${cartState.total.toStringAsFixed(2)}'),
          const SizedBox(height: AppDimensions.spacingXxl),
          ElevatedButton(
            onPressed: () {
              context.read<CheckoutCubit>().reset();
              context.go(RoutesPath.menu);
            },
            child: const Text('Continue browsing'),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          TextButton(
            onPressed: () {
              context.read<CheckoutCubit>().reset();
              context.go(RoutesPath.orders);
            },
            child: const Text('View orders'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label:', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
