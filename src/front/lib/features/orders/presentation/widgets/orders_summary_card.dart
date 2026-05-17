import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_surface_card.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';

class OrdersSummaryCard extends StatelessWidget {
  const OrdersSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OrdersSurfaceCard(
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final allOrders = [...state.activeOrders, ...state.pastOrders];
          final now = DateTime.now();
          final ordersThisMonth = allOrders.where((o) =>
              o.placedAt.year == now.year && o.placedAt.month == now.month).length;
          final totalSpent = allOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText('Quick summary', style: textTheme.headlineMedium),
              const SizedBox(height: AppDimensions.spacingXl),
              _SummaryLine(label: 'Orders this month', value: '$ordersThisMonth'),
              const SizedBox(height: AppDimensions.spacingMd),
              _SummaryLine(label: 'Total spent', value: '\$${totalSpent.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SelectableText(label, style: textTheme.bodyLarge),
        const Spacer(),
        SelectableText(
          value,
          style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }
}
