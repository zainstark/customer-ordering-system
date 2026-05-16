import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_main_column.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_section_header.dart';
import 'package:frontend/features/orders/presentation/widgets/orders_summary_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state.status == OrdersRequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == OrdersRequestStatus.error) {
          return _StateMessage(
            message:
                state.errorMessage ??
                'Something went wrong while loading orders.',
            onRetry: () => context.read<OrdersCubit>().loadOrders(),
          );
        }

        if (state.status == OrdersRequestStatus.success &&
            state.activeOrders.isEmpty &&
            state.pastOrders.isEmpty) {
          return _StateMessage(
            message: 'No orders available right now.',
            onRetry: () => context.read<OrdersCubit>().loadOrders(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrdersSectionHeader(
                title: 'Orders history',
                subtitle: 'Track and manage your recent deliveries.',
                trailing: SegmentedButton<OrdersTab>(
                  segments: const [
                    ButtonSegment(
                      value: OrdersTab.active,
                      label: SelectableText('Active'),
                    ),
                    ButtonSegment(
                      value: OrdersTab.past,
                      label: SelectableText('Past orders'),
                    ),
                  ],
                  selected: {state.selectedTab},
                  onSelectionChanged: (tabs) =>
                      context.read<OrdersCubit>().changeTab(tabs.first),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              isDesktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: OrdersMainColumn()),
                        SizedBox(width: AppDimensions.spacingLg),
                        Expanded(flex: 2, child: OrdersSummaryCard()),
                      ],
                    )
                  : const Column(
                      children: [
                        OrdersMainColumn(),
                        SizedBox(height: AppDimensions.spacingLg),
                        OrdersSummaryCard(),
                      ],
                    ),
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
