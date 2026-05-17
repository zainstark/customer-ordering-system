import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:frontend/features/checkout/presentation/widgets/payment_error_card.dart';
import 'package:frontend/features/checkout/presentation/widgets/retry_payment_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CheckoutCubit>().state;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppDimensions.spacingXxxl),
          const Icon(Icons.cancel_outlined, size: 92, color: Colors.redAccent),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'Payment failed',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            state.paymentMessage ?? 'We could not complete your payment.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          if (state.errorMessage != null)
            PaymentErrorCard(message: state.errorMessage!),
          const SizedBox(height: AppDimensions.spacingLg),
          RetryPaymentButton(
            onRetry: () => context.read<CheckoutCubit>().retryPayment(),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ElevatedButton(
            onPressed: () => context.go(RoutesPath.checkout),
            child: const Text('Choose another payment method'),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          TextButton(
            onPressed: () => context.go(RoutesPath.cart),
            child: const Text('Return to cart'),
          ),
        ],
      ),
    );
  }
}
