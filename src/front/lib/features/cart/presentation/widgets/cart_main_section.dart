import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:frontend/features/cart/presentation/widgets/cart_section_header.dart';

class CartMainSection extends StatelessWidget {
  const CartMainSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CartSectionHeader(
          title: 'Your cart',
          subtitle: 'Review your selected dishes before checkout.',
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        ...cartState.models.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
            child: CartItemCard(
              model: item,
              onIncrement: () =>
                  context.read<CartCubit>().incrementItem(item.id),
              onDecrement: () =>
                  context.read<CartCubit>().decrementItem(item.id),
            ),
          );
        }),
      ],
    );
  }
}
