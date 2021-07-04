import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/order_item.dart';
import '../models/cart_item.dart';

class OrdersProviders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [
      ..._orders
    ]; //we are returning copy so that outside of this class we can't edit it.
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
        'myshop-theflutterapp-default-rtdb.firebaseio.com', '/orders.json');
    final response = await http.get(url);
    // print('received orders : ${json.decode(response.body)}');
    final List<OrderItem> loadedOrders = [];
    // final extractedData = json.decode(response.body);
    var extractedData;
    try {
      extractedData = json.decode(response.body) as Map<String, dynamic>;
    } catch (error) {
      print('orders data not found.');

      //additional codes for local storage :
      _orders = [];
      notifyListeners();
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'myshop-theflutterapp-default-rtdb.firebaseio.com', '/orders.json');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(), //accepted format conversion.
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
      ),
    );
    notifyListeners();
  }
}
