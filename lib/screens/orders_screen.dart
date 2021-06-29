import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/orders_provider.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<OrdersProviders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: (ordersData.orders.length == 0)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    './assets/animations/empty_box.json',
                    repeat: false,
                  ),
                  Text(
                    'Not placed any orders yet.',
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Start ordering some!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: ordersData.orders.length,
              itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
            ),
    );
  }
}
