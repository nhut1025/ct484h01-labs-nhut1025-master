import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/app_drawer.dart';
import 'orders_manager.dart';
import 'order_item_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: Consumer<OrdersManager>(
        builder: (_, ordersManager, __) {
          if (ordersManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ordersManager.orderCount == 0) {
            return const Center(
              child: Text('You have no orders yet.'),
            );
          }

          return RefreshIndicator(
            onRefresh: ordersManager.fetchOrders,
            child: ListView.builder(
              itemCount: ordersManager.orderCount,
              itemBuilder: (ctx, i) => OrderItemCard(
                ordersManager.orders[i],
              ),
            ),
          );
        },
      ),
    );
  }
}
