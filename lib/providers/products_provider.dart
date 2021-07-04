import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  //mixin can be added with 'with' keyword which is used to merge some properties to existing class. bit like Inheritance lite.
  //Only one parent can be supported in dart but mixin can be as many as you want.
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'Half Pant',
    //   description:
    //       'A cool addition to your wardrobe, these shorts are Lightweight and breathable, they will keep you comfortable all day long.',
    //   price: 30.99,
    //   imageUrl:
    //       'https://images-na.ssl-images-amazon.com/images/I/61u54mYKxLS._UX466_.jpg',
    // )
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

  Future<void> addProduct(Product newProduct) async {
    final url = Uri.https(
        'myshop-theflutterapp-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
          'isFavorite': newProduct.isFavorite,
        }),
      );
      print(json.decode(response.body));

      newProduct = Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    print(
        'PRODUCT ADDED to FIREBASE : ${newProduct.id} ${newProduct.title} ${newProduct.price} ${newProduct.description} ${newProduct.imageUrl} ${newProduct.isFavorite}');
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.https('myshop-theflutterapp-default-rtdb.firebaseio.com',
        '/products/$id.json');
    try {
      //server updation :
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));

      //local updation :
      final prodIndex = _items.indexWhere((product) => product.id == id);
      if (prodIndex >= 0) {
        _items[prodIndex] = newProduct;
      } else {
        print('product id is not found for updation. id was $id.');
      }
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
    print(
        'PRODUCT UPDATED WITH : ${newProduct.id} ${newProduct.title} ${newProduct.price} ${newProduct.description} ${newProduct.imageUrl} ${newProduct.isFavorite}');
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  void showAlertDialogMessage(
    BuildContext context,
    String titleMessage,
    String contentMessage,
    String buttonTitle,
  ) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
            // 'Something went wrong!\nError message : ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    }
  }

  Future<void> deleteProduct(BuildContext context, String id) async {
    final url = Uri.https('myshop-theflutterapp-default-rtdb.firebaseio.com',
        '/products/$id.json');

    //save product which is to be deleted.
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    Product? existingProduct = _items[existingProductIndex];
    // _items.removeAt(existingProductIndex);
    // _items.removeWhere((product) => product.id == id);

    final response = await http.delete(url);
    try {
      print(response.statusCode);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product.');
      }
      _items.removeAt(existingProductIndex);
      notifyListeners();
      existingProduct = null;
    } catch (error) {
      //ROLLBACK approach if error caught.
      print('AN ERROR OCCURRED WHILE DELETION : ${error.toString()}');
      showAlertDialogMessage(context, 'Something went wrong!',
          'Could not delete ${existingProduct!.title}', 'Okay');
      // _items.insert(existingProductIndex, existingProduct!);
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'myshop-theflutterapp-default-rtdb.firebaseio.com', '/products.json');

    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      var extractedData;
      try {
        extractedData = json.decode(response.body) as Map<String, dynamic>;
      } catch (error) {
        print('Products data not found.');
        return;
      }

      print('\n\nextracted data : $extractedData');
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (productId, productData) {
          print(
              '\nFOR $productId : \n\t${productData['title']}\n\t${productData['price']}\n\t${productData['description']}\n\t${productData['imageUrl']}\n\t${productData['isFavorite']}');
          loadedProducts.add(
            Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              isFavorite: productData['isFavorite'],
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
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

/*
Database rules of firebase before : 
{
  "rules": {
    ".read": "now < 1627842600000",  // 2021-8-2
    ".write": "now < 1627842600000",  // 2021-8-2
  }
}
After : 
{
  "rules": {
    ".read": true,  // 2021-8-2
    ".write": true,  // 2021-8-2
  }
}
*/

/*
//ADD PRODUCT FUNCTION WITH THEN() AND CATCHERROR()
Future<void> addProduct(Product newProduct) {
    //http requests can take some time so we are sending the http request first before executing our addition product logic.
    // final url = Uri.parse(
    //     'https://myshop-theflutterapp-default-rtdb.firebaseio.com/products.json ');
    //alternatively we can also use this :
    final url = Uri.https(
        'myshop-theflutterapp-default-rtdb.firebaseio.com', '/products.json');
    //here at the end of URL we can write anything which firebase converts into query and creates the folder of the name we provided. Here a folder named 'products' will be created.
    return http
        .post(
      url,
      body: json.encode({
        'title': newProduct.title,
        'descrption': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
        'isFavorite': newProduct.isFavorite,
      }),
    )
        .then((response) {
      //this response is sent to us from firebase.
      print(json.decode(response.body));
      //this inside then  function will only execute when the above future code completed.

      newProduct = Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0,newProduct);    //insert product at beginning of the list

      notifyListeners(); //classes that are listening to this notifier will be changed when this method is called. the updates we are made will be changed to every class which are listening to this class/rebuild class.

      print(
          'PRODUCT ADDED to FIREBASE : ${newProduct.id} ${newProduct.title} ${newProduct.price} ${newProduct.description} ${newProduct.imageUrl} ${newProduct.isFavorite}');

      // return Future.value(newProduct.title); //this will not work as it is inside the nested function.
      // return Future.value(newProduct.title);
    }).catchError((error) {
      print(error);
      throw error; //again throwing error.
    }); //this block will catch errors in both above blocks.
    /*
    //Named arguments 
    headers : meta data can be attached here
    body : request body => wants JSON = JavaScript Object Notation
    */
  }
*/
