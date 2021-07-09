import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/cupertino.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  // const EditProductScreen({Key? key}) : super(key: key);
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

enum Choice {
  title,
  price,
  description,
  imageUrl,
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _titleFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  // final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  var imageUrlInputValue = '';
  final _form = GlobalKey<FormState>();
  bool _isNewProduct = false;

  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
    seller: '',
  );

  var _isInit = true;
  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
    'seller': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode
        .addListener(_updateImageUrl); //this is only pointer to the function.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      String productId;
      final parsedDoubleID = double.tryParse(
          ModalRoute.of(context)!.settings.arguments.toString());
      if (parsedDoubleID == null && parsedDoubleID != -1) {
        productId = ModalRoute.of(context)!.settings.arguments as String;
      } else {
        productId = '-1'; //this means is new product
        _isNewProduct = true;
      }
      // String? productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != '-1') {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': _editedProduct.imageUrl,
          'seller': _editedProduct.seller,
        };
        imageUrlInputValue = _initValues['imageUrl'] as String;
      }
    }
    _isInit = false;
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

// currently this function is not in use.
  void checkURL(String url) {
    var urlPattern =
        r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    var result = new RegExp(urlPattern, caseSensitive: false).firstMatch(url);
    print('result returned : $result');
  }

//this function is not in use currently. it was before i learned validator method. so it basically shows error messages through snackbars.
  void showSnackBarMessage(
    var context,
    var message,
    Choice choice,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'ENTER',
          onPressed: () {
            // cart.addItem(product.id, product.price, product.title);
            if (choice == Choice.title) {
              FocusScope.of(context).requestFocus(_titleFocusNode);
            } else if (choice == Choice.price) {
              FocusScope.of(context).requestFocus(_priceFocusNode);
            } else if (choice == Choice.description) {
              FocusScope.of(context).requestFocus(_descriptionFocusNode);
            } else {
              FocusScope.of(context).requestFocus(_imageUrlFocusNode);
            }
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
      ),
    );
  }

  Future<void> showAlertDialogMessage(
    BuildContext context,
    String titleMessage,
    String contentMessage,
    String buttonTitle,
  ) async {
    if (Platform.isAndroid) {
      await showDialog(
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
                setState(() {
                  _isLoading = false;
                });
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    } else {
      await showCupertinoDialog(
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
                setState(() {
                  _isLoading = false;
                });
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveForm(String id) async {
    //validating manually
    final isValid = _form.currentState!
        .validate(); //return false if atleast one validator has not returned null.
    if (!isValid) {
      return; //cancels the function execution if there is atleast one value is not valid.
    }
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id == '') {
      //if the screen is for ADD PRODUCT
      print('product added.');
      _editedProduct = _editedProduct.copyWith(id: id);
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct, context);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      } catch (error) {
        print(
            'AN ERROR OCCURRED WHILE ADDING THE PRODUCT: ${error.toString()}');
        showAlertDialogMessage(
            context, 'An error occurred!', 'Something went wrong.', 'Okay');
        // if (Platform.isAndroid) {
        //   await showDialog(
        //     context: context,
        //     builder: (ctx) => AlertDialog(
        //       title: Text('An error occurred!'),
        //       content: Text(
        //         'Something went wrong.',
        //         // 'Something went wrong!\nError message : ${error.toString()}',
        //       ),
        //       actions: [
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(ctx).pop();
        //             setState(() {
        //               _isLoading = false;
        //             });
        //           },
        //           child: Text('Okay'),
        //         ),
        //       ],
        //     ),
        //   );
        // } else {
        //   await showCupertinoDialog(
        //     context: context,
        //     builder: (ctx) => CupertinoAlertDialog(
        //       title: Text('An error occurred!'),
        //       content: Text(
        //         'Something went wrong.',
        //       ),
        //       actions: [
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(ctx).pop();
        //             setState(() {
        //               _isLoading = false;
        //             });
        //           },
        //           child: Text('Okay'),
        //         ),
        //       ],
        //     ),
        //   );
        // }
      }
      // finally {    //if we apply finally then if error occurred, and user press okay, then user will lost all entered data and he cannot retrieve it so we are applying this  code  snippet into the try block itself. so if there is no error then only this loading spinner  will close and the main user product screen will appear.
      // setState(() {
      //   _isLoading = false;
      // });
      // Navigator.of(context).pop();
      // }
    } else {
      //if the screen is for EDIT PRODUCT
      print('product edited');
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      } catch (error) {
        print(
            'AN ERROR OCCURRED WHILE UPDATING THE PRODUCT: ${error.toString()}');
        showAlertDialogMessage(
            context, 'An error occurred!', 'Something went wrong.', 'Okay');
      }
      // setState(() {
      //   _isLoading = false;
      // });
      // Navigator.of(context).pop();
    }

    // print('id getting is $id');

    print(
        'Submitted this : ${_editedProduct.id} ${_editedProduct.title} ${_editedProduct.description} ${_editedProduct.imageUrl} ${_editedProduct.isFavorite}');
    // Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    //for avoiding memory leaks, we should dispose the focusNodes and controllers.
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    // _imageUrlController.dispose();
    //removing listeners and then disposing the focusNode.
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductsProvider>(context, listen: false);
    final items = productData.items;
    return Scaffold(
      appBar: AppBar(
        title: _isNewProduct ? Text('Add Product') : Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: () {
              // final id = 'p${items.length + 1}';
              final id = '';
              // print('id generated is $id');
              _saveForm(id);
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Lottie.asset(
                        'assets/animations/loading_paperplane.json',
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        '${(_isNewProduct) ? 'Adding' : 'Updating'} ${_editedProduct.title}...',
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        focusNode: _titleFocusNode,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(
                              _priceFocusNode); //go to price field when pressed next.
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a title.';
                          }
                          return null; //returning null means input is correct
                        },
                        onSaved: (value) {
                          if (value!.length == 0) {
                            showSnackBarMessage(
                                context, 'Enter valid title.', Choice.title);
                            return;
                          }
                          _editedProduct =
                              _editedProduct.copyWith(title: value);
                          _initValues['title'] = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a price.';
                          }
                          if (double.tryParse(value) == null) {
                            //if it returned the null then parsing is failed so the price value is not valid.
                            return 'Please enter a valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          if (value!.length == 0) {
                            showSnackBarMessage(
                                context, 'Enter valid price.', Choice.price);
                            return;
                          }
                          _editedProduct = _editedProduct.copyWith(
                              price: double.parse(value));
                          _initValues['price'] = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        // textInputAction: TextInputAction.next, //this is not needed for multiline text field as there will be an enter button instead of next button for going to next line in the input field.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a description.';
                          }
                          if (value.length < 10) {
                            return 'Description should be at least 10 characters long.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(
                              _priceFocusNode); //go to price field when pressed next.
                        },
                        onSaved: (value) {
                          if (value!.length == 0) {
                            showSnackBarMessage(context,
                                'Enter valid description.', Choice.description);
                            return;
                          }
                          _editedProduct =
                              _editedProduct.copyWith(description: value);
                          _initValues['description'] = value;
                        },
                      ),
                      // container for product image preview:
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              width: MediaQuery.of(context).size.width / 1.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                                // borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              child: TextFormField(
                                initialValue: _initValues['imageUrl'],
                                // style: TextStyle(color: Colors.white),
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  // checkURL(value!);

                                  if (value!.isEmpty) {
                                    return 'Please provide an image URL.';
                                  } else {
                                    // return 'Please enter a valid image URL.';
                                    return null;
                                  }
                                  // if (!value.startsWith('http') &
                                  //     !value.startsWith('https')) {
                                  //   return 'Please enter a valid URL.';
                                  // }
                                  // if (!value.endsWith('.png') &&
                                  //     !value.endsWith('.jpg') &&
                                  //     !value.endsWith('.jpeg')) {
                                  //   return 'Please enter a valid image URL.';
                                  // }
                                },
                                onFieldSubmitted: (_) {
                                  final id = 'p${items.length + 1}';
                                  // print('id generated is $id');
                                  _saveForm(id);
                                },
                                // controller: _imageUrlController,
                                focusNode:
                                    _imageUrlFocusNode, //when user unselect this focus then we will show the preview.
                                onChanged: (value) {
                                  setState(() {
                                    imageUrlInputValue = value;
                                    // print('new value is $imageUrlInputValue');
                                  });
                                },
                                onEditingComplete: () {
                                  setState(() {});
                                  FocusScope.of(context)
                                      .unfocus(); //hide on-screen keyboard.
                                },
                                onSaved: (value) {
                                  if (value!.length == 0) {
                                    showSnackBarMessage(context,
                                        'Enter Image URL.', Choice.imageUrl);
                                    return;
                                  }
                                  _editedProduct =
                                      _editedProduct.copyWith(imageUrl: value);
                                  _initValues['imageUrl'] = value;
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  // border: Border.all(width: 2, color: Colors.blue),
                                  ),
                              child: (imageUrlInputValue.length == 0)
                                  ? Text('Enter URL to see the preview!')
                                  : Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio:
                                              1, //forcing image to square shape
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10), //applied circular border radius to the image.
                                            child: FadeInImage.assetNetwork(
                                              image: imageUrlInputValue,
                                              placeholder:
                                                  'assets/images/product-placeholder.png',
                                              imageErrorBuilder: (context,
                                                      error, stackTrace) =>
                                                  Column(
                                                children: [
                                                  Image.asset(
                                                      'assets/images/error-placeholder.png'),
                                                  Text(
                                                      'Entered URL is broken!'),
                                                ],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 20,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // color: Colors.black54,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black,
                                                  Colors.black.withOpacity(0.1)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                bottomLeft: Radius.circular(5),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 20),
                                            width: 150,
                                            child: Text(
                                              'Preview',
                                              style: TextStyle(
                                                fontSize: 26,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


/*
//old approach for displaying preview image : 
Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      // child: _imageUrlController.text.isEmpty
                      child: (imageUrlInputValue.length == 0)
                          ? Text('Enter a URL')
                          : Text('Entered url.'),
                      // FittedBox(
                      //     child: Image.network(imageUrlInputValue),
                      //     fit: BoxFit.cover,
                      //   ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        // controller: _imageUrlController,
                        focusNode:
                            _imageUrlFocusNode, //when user unselect this focus then we will show the preview.
                        onChanged: (value) {
                          setState(() {
                            imageUrlInputValue = value;
                          });
                        },
                        onEditingComplete: () {
                          setState(() {});
                          FocusScope.of(context)
                              .unfocus(); //hide on-screen keyboard.
                        },
                      ),
                    ),
                  ],
                ),
*/


/*
//OLD SAVEFORM METHOD WITHOUT ASYNC
void _saveForm(String id) {
    //validating manually
    final isValid = _form.currentState!
        .validate(); //return false if atleast one validator has not returned null.
    if (!isValid) {
      return; //cancels the function execution if there is atleast one value is not valid.
    }
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id == '') {
      //if the screen is for ADD PRODUCT
      print('product added.');
      _editedProduct = _editedProduct.copyWith(id: id);
      Provider.of<ProductsProvider>(context, listen: false)
          .addProduct(_editedProduct)
          .catchError((error) {
        return (Platform.isAndroid)
            ? showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text(
                    'Something went wrong.',
                    // 'Something went wrong!\nError message : ${error.toString()}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: Text('Okay'),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.of(ctx).pop();
                    //     setState(() {
                    //       _isLoading = false;
                    //     });
                    //     _saveForm(id);
                    //   },
                    //   child: Text('Retry'),
                    // ),
                  ],
                ),
              )
            : showCupertinoDialog(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: Text('An error occurred!'),
                  content: Text(
                    'Something went wrong.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: Text('Okay'),
                    ),
                  ],
                ),
              );
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      //if the screen is for EDIT PRODUCT
      print('product edited');
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }

    // print('id getting is $id');

    print(
        'Submitted this : ${_editedProduct.id} ${_editedProduct.title} ${_editedProduct.description} ${_editedProduct.imageUrl} ${_editedProduct.isFavorite}');
    // Navigator.of(context).pop();
  }
*/

/*
old loading body: 
SingleChildScrollView(
              child: Center(
                // child: Stack(
                //   alignment: Alignment.center,
                //   children: [
                //     Lottie.asset(
                //       'assets/animations/loading_paperplane.json',
                //       // height: 300,
                //     ),
                //     Positioned(
                //       bottom: (MediaQuery.of(context).orientation ==
                //               Orientation.portrait)
                //           ? MediaQuery.of(context).size.height / 20
                //           : MediaQuery.of(context).size.height / 8,
                //       child: Text(
                //         'Adding ${_editedProduct.title}...',
                //         style: TextStyle(
                //           fontSize: 30,
                //           color: Theme.of(context).primaryColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),

                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/loading_paperplane.json',
                        width: MediaQuery.of(context).size.width / 1.5,
                      ),
                      // CircularProgressIndicator(), //old method
                      // SizedBox(
                      //   height: 10,
                      // ),
                      Text(
                        '${(_isNewProduct) ? 'Adding' : 'Updating'} ${_editedProduct.title}...',
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
*/