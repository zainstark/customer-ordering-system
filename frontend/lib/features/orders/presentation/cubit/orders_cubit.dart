import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/orders/data/models/order_item_model.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit()
    : super(
        OrdersState(
          selectedTab: OrdersTab.active,
          activeOrders: [
            OrderItemModel(
              id: 'o1',
              accountId: 'ACC-100',
              orderId: 'ORD-8821',
              status: 'Preparing',
              placedAt: DateTime(2026, 05, 12, 12, 45),
              totalAmount: 34.50,
              progress: .45,
            ),
            OrderItemModel(
              id: 'o2',
              accountId: 'ACC-100',
              orderId: 'ORD-8794',
              status: 'Out for delivery',
              placedAt: DateTime(2026, 05, 12, 11, 15),
              totalAmount: 52.20,
              progress: .72,
            ),
          ],
          pastOrders: [
            OrderItemModel(
              id: 'o3',
              accountId: 'ACC-100',
              orderId: 'ORD-7701',
              status: 'Delivered',
              placedAt: DateTime(2026, 05, 10, 21, 12),
              totalAmount: 45.00,
              progress: 1,
            ),
            OrderItemModel(
              id: 'o4',
              accountId: 'ACC-100',
              orderId: 'ORD-7692',
              status: 'Delivered',
              placedAt: DateTime(2026, 05, 08, 18, 45),
              totalAmount: 28.15,
              progress: 1,
            ),
          ],
        ),
      );

  void changeTab(OrdersTab tab) {
    if (state.selectedTab == tab) return;
    emit(state.copyWith(selectedTab: tab));
  }
}

enum OrdersTab { active, past }
