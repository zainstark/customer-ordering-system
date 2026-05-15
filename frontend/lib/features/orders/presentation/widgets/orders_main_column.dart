import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/widgets/order_status_card.dart';

class OrdersMainColumn extends StatelessWidget {
  const OrdersMainColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrdersCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...state.visibleOrders.map((order) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
            child: OrderStatusCard(order: order),
          );
        }),
      ],
    );
  }
}
