import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/widgets/cart_summary_card.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:frontend/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:frontend/features/checkout/presentation/widgets/checkout_action_button.dart';
import 'package:frontend/features/checkout/presentation/widgets/checkout_header.dart';
import 'package:frontend/features/checkout/presentation/widgets/checkout_item_tile.dart';
import 'package:frontend/features/checkout/presentation/widgets/payment_method_card.dart';
import 'package:frontend/features/checkout/presentation/widgets/secure_payment_banner.dart';
import 'package:frontend/features/checkout/presentation/widgets/payment_error_card.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocConsumer<CheckoutCubit, CheckoutState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == CheckoutRequestStatus.awaitingPayment) {
              context.go(RoutesPath.paymentProcessing);
            }
            if (state.status == CheckoutRequestStatus.failure) {
              context.go(RoutesPath.paymentFailure);
            }
            // When CASH payment succeeds, ensure notification UI updates immediately
            if (state.status == CheckoutRequestStatus.success) {
              context.read<NotificationCubit>().loadNotifications();
              context.read<NotificationBadgeCubit>().refresh();
              // Navigate to orders page after a brief delay to allow state updates
              Future.delayed(const Duration(milliseconds: 500), () {
                context.go(RoutesPath.orders);
              });
            }
          },
          builder: (context, state) {
            final width = MediaQuery.sizeOf(context).width;
            final isWide = width >= 1000;

            if (state.status == CheckoutRequestStatus.validatingCart ||
                state.status == CheckoutRequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CheckoutRequestStatus.failure && cartState.models.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingXl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: AppDimensions.spacingLg),
                      Text(state.errorMessage ?? 'Unable to load checkout.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppDimensions.spacingLg),
                      ElevatedButton(
                        onPressed: () => context.read<CheckoutCubit>().loadCheckout(),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final paymentOptions = PaymentMethodType.values;

            final paymentSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CheckoutHeader(
                  title: 'Secure Payment',
                  subtitle: 'Choose a payment method to complete your order.',
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                ...paymentOptions.map((method) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                    child: PaymentMethodCard(
                      method: method,
                      selected: state.selectedMethod == method,
                      onTap: () => context.read<CheckoutCubit>().selectPaymentMethod(method),
                    ),
                  );
                }),
                const SizedBox(height: AppDimensions.spacingLg),
                const SecurePaymentBanner(),
                const SizedBox(height: AppDimensions.spacingLg),
                if (state.errorMessage != null)
                  PaymentErrorCard(message: state.errorMessage!),
                CheckoutActionButton(
                  label: 'Complete Purchase',
                  isBusy: state.status == CheckoutRequestStatus.creatingOrder ||
                      state.status == CheckoutRequestStatus.creatingPaymentIntent,
                  onPressed: cartState.models.isNotEmpty
                      ? () => context.read<CheckoutCubit>().placeOrder(address: '123 Default Street')
                      : () {},
                ),
              ],
            );

            final cartSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CheckoutHeader(
                  title: 'Checkout',
                  subtitle: 'Review your details and select a payment method.',
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                if (cartState.models.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingXl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: const Text('No items available for checkout.'),
                  )
                else ...cartState.models.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                    child: CheckoutItemTile(item: item),
                  ),
                ),
              ],
            );

            final summarySection = CartSummaryCard(state: cartState, button: false);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: cartSection),
                        const SizedBox(width: AppDimensions.spacingLg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              paymentSection,
                              const SizedBox(height: AppDimensions.spacingLg),
                              summarySection,
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cartSection,
                        const SizedBox(height: AppDimensions.spacingXxl),
                        paymentSection,
                        const SizedBox(height: AppDimensions.spacingLg),
                        summarySection,
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

