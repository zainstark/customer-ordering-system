import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_main_section.dart';
import 'package:frontend/features/widgets/cart_summary_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.status == CartRequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == CartRequestStatus.error) {
          return _StateMessage(
            message:
                state.errorMessage ??
                'Something went wrong while loading cart.',
            onRetry: () => context.read<CartCubit>().loadCart(),
          );
        }

        if (state.status == CartRequestStatus.success && state.models.isEmpty) {
          return _StateMessage(
            message: 'Your cart is empty.',
            onRetry: () => context.read<CartCubit>().loadCart(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 3, child: CartMainSection()),
                    const SizedBox(width: AppDimensions.spacingLg),
                    Expanded(
                      flex: 1,
                      child: CartSummaryCard(state: state, button: true),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CartMainSection(),
                    const SizedBox(height: AppDimensions.spacingLg),
                    CartSummaryCard(state: state, button: true),
                  ],
                ),
        );
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: AppDimensions.spacingMd),
            SelectableText(message, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spacingMd),
            ElevatedButton(
              onPressed: onRetry,
              child: const SelectableText('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
