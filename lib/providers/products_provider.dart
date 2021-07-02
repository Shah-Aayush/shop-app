import 'package:flutter/material.dart';

import './product.dart';

class ProductsProvider with ChangeNotifier {
  //mixin can be added with 'with' keyword which is used to merge some properties to existing class. bit like Inheritance lite.
  //Only one parent can be supported in dart but mixin can be as many as you want.
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
    Product(
      id: 'p5',
      title: 'Half Pant',
      description:
          'A cool addition to your wardrobe, these shorts are Lightweight and breathable, they will keep you comfortable all day long.',
      price: 30.99,
      imageUrl:
          'https://images-na.ssl-images-amazon.com/images/I/61u54mYKxLS._UX466_.jpg',
    )
  ]; //this should never be accessible from outside. this can be change over time.

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [
      ..._items
    ]; //used spreader so that it will return the copy of items. As I don't want to return pointer of reference to the original list of items.
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  void addProduct(Product newProduct) {
    _items.add(newProduct);
    // _items.insert(0,newProduct);    //insert product at beginning of the list

    notifyListeners(); //classes that are listening to this notifier will be changed when this method is called. the updates we are made will be changed to every class which are listening to this class/rebuild class.
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((product) => product.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      print(
          'PRODUCT UPDATED WITH : ${newProduct.id} ${newProduct.title} ${newProduct.price} ${newProduct.description} ${newProduct.imageUrl} ${newProduct.isFavorite}');
    } else {
      print('product id is not found for updation.');
    }
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  void deleteProduct(String id) {
    _items.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}
