import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_state.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_main_section.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_order_summary_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
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
                      child: CartOrderSummaryCard(state: state),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CartMainSection(),
                    const SizedBox(height: AppDimensions.spacingLg),
                    CartOrderSummaryCard(state: state),
                  ],
                ),
        );
      },
    );
  }
}
