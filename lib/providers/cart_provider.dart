import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  bool isPresentInCart(String id) {
    return _items.containsKey(id);
  }

  int getQuantity(String id) {
    if (_items.containsKey(id)) {
      return _items[id]!.quantity;
    }
    return 0;
  }

  void removeItem(String id) {
    if (!_items.containsKey(id)) {
      print('Item is not in the cart.');
      return;
    }
    _items.remove(id);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    _items.update(
      productId,
      (CartItem existingCartItem) => CartItem(
        id: existingCartItem.id,
        title: existingCartItem.title,
        quantity: existingCartItem.quantity + 1,
        price: existingCartItem.price,
      ),
    );
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    _items.update(
      productId,
      (CartItem existingCartItem) => CartItem(
        id: existingCartItem.id,
        title: existingCartItem.title,
        quantity: existingCartItem.quantity - 1,
        price: existingCartItem.price,
      ),
    );
    notifyListeners();
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      increaseQuantity(productId);
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
                id: productId,
                title: title,
                quantity: 1,
                price: price,
              ));
      notifyListeners();
    }
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
