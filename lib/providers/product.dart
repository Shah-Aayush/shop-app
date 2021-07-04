import 'dart:convert';

import 'package:flutter/material.dart'; //ChangeNotifier is located in this or foundation .dart
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    print('favorite toggle pressed.CURRENT status : $isFavorite.');
    final url = Uri.https('myshop-theflutterapp-default-rtdb.firebaseio.com',
        '/products/$id.json');
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    print('temp status updated.');
    try {
      final response = await http.patch(url,
          body: json.encode({
            'isFavorite': isFavorite,
          }));
      if (response.statusCode >= 400) {
        throw HttpException('Could not favorite the item.');
      }
      print('favorite operation succeed.');
    } catch (error) {
      print('favorite operation failed.');
      isFavorite = oldStatus;
      notifyListeners();
      throw error;
    }
    print('UPDATED status : $isFavorite');
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}


/*
//OLD TOGGLE : 

    // try {
    //   //server updation :
    //   await http.patch(url,
    //       body: json.encode({
    //         'title': title,
    //         'description': description,
    //         'price': price,
    //         'imageUrl': imageUrl,
    //         'isFavorite': !isFavorite,
    //       }));

    //   //local updation :
    //   isFavorite = !isFavorite;
    //   notifyListeners();
    // } catch (error) {
    //   print(
    //       'AN ERROR OCCURRED WHILE FAVORATING THE PRODUCT : ${error.toString()}');
    //   throw error;
    // }
    // print(
    //     'PRODUCT UPDATED WITH : ${newProduct.id} ${newProduct.title} ${newProduct.price} ${newProduct.description} ${newProduct.imageUrl} ${newProduct.isFavorite}');

    // notifyListeners(); //this is kind of stateState method in stateful widget.
*/