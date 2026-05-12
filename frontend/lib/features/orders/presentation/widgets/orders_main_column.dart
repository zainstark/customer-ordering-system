import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/widgets/order_status_card.dart';
import 'package:frontend/features/orders/presentation/widgets/recent_order_tile.dart';

class OrdersMainColumn extends StatelessWidget {
  const OrdersMainColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
        const SizedBox(height: AppDimensions.spacingXl),
        Text('Recent orders', style: textTheme.headlineMedium),
        const SizedBox(height: AppDimensions.spacingMd),
        const RecentOrderTile(
          title: 'SushiZen Master',
          subtitle: 'Oct 24 • \$45.00 • Completed',
          icon: Icons.set_meal_outlined,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        const RecentOrderTile(
          title: 'Mama Mia Pizza',
          subtitle: 'Oct 22 • \$28.15 • Completed',
          icon: Icons.local_pizza_outlined,
        ),
      ],
    );
  }
}
