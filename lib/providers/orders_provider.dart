import 'package:flutter/foundation.dart';

import '../models/order_item.dart';
import '../models/cart_item.dart';

class OrdersProviders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [
      ..._orders
    ]; //we are returning copy so that outside of this class we can't edit it.
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
