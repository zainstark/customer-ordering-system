import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/presentation/cubit/order_cubit.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final orderId = state.order?.orderId ?? '—';
        final total = state.order?.totalAmount.toStringAsFixed(2) ?? '0.00';

        return Scaffold(
          appBar: AppBar(title: const Text('Payment')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order: ${orderId.length > 8 ? orderId.substring(0,8) : orderId}'),
                const SizedBox(height: 8),
                Text('Amount: \$$total'),
                const SizedBox(height: 16),
                if (state.status == OrderRequestStatus.loading)
                  const Center(child: CircularProgressIndicator()),
                if (state.status == OrderRequestStatus.error)
                  Text('Error: ${state.errorMessage}'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement payment integration here using state.order?.orderId
                      // e.g. call payment SDK and pass orderId for reconciliation.
                    },
                    child: const Text('Pay'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
