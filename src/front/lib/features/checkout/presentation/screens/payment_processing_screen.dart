import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:frontend/features/checkout/presentation/widgets/payment_processing_indicator.dart';
import 'package:frontend/features/checkout/presentation/widgets/payment_status_banner.dart';
import 'package:frontend/features/checkout/presentation/widgets/retry_payment_button.dart';

class PaymentProcessingScreen extends StatelessWidget {
  const PaymentProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CheckoutRequestStatus.success) {
          context.go(RoutesPath.paymentSuccess);
        }
        if (state.status == CheckoutRequestStatus.failure) {
          context.go(RoutesPath.paymentFailure);
        }
      },
      builder: (context, state) {
        final message = state.paymentMessage ?? 'Processing your payment. Please wait...';

        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.spacingXxxl),
              Text(
                'Payment processing',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              PaymentProcessingIndicator(message: message),
              const SizedBox(height: AppDimensions.spacingXxl),
              if (state.status == CheckoutRequestStatus.awaitingPayment ||
                  state.status == CheckoutRequestStatus.processing)
                ElevatedButton(
                  onPressed: () => context.read<CheckoutCubit>().refreshPaymentStatus(),
                  child: const Text('Refresh status'),
                ),
              const SizedBox(height: AppDimensions.spacingMd),
              RetryPaymentButton(
                onRetry: () => context.read<CheckoutCubit>().retryPayment(),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              TextButton(
                onPressed: () => context.go(RoutesPath.checkout),
                child: const Text('Return to checkout'),
              ),
            ],
          ),
        );
      },
    );
  }
}
