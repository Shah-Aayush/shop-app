import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth.dart';

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late ScrollController _controller;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool fabIsVisible = true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _controller = ScrollController();
    _controller.addListener(() {
      setState(() {
        fabIsVisible =
            _controller.position.userScrollDirection == ScrollDirection.forward;
        if (fabIsVisible) {
          _slideController.reverse();
        } else {
          _slideController.forward();
        }
      });
    });

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset(0, 2),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
  }

  Color lighten(Color color, [double amount = .1]) {
    //lighten the color
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  void toggleItemInCart(var product, var cart, var context) {
    if (cart.isPresentInCart(product.id)) {
      cart.removeItem(product.id);
      print('${product.title} removed from the cart');

      //hide current snackbar message and show new snackbar.
      // ScaffoldMessenger.of(context).hideCurrentSnackBar(); //hiding snackbar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   //showing new snackbar with action button
      //   SnackBar(
      //     content: Text(
      //       '${product.title} removed from the cart!',
      //     ),
      //     duration: Duration(seconds: 2),
      //     action: SnackBarAction(
      //       label: 'UNDO',
      //       onPressed: () {
      //         cart.addItem(product.id, product.price, product.title);
      //       },
      //     ),
      //   ),
      // );
    } else {
      cart.addItem(product.id, product.price, product.title);
      print('${product.title} added to the cart');
      // Scaffold.of(context).openDrawer(); //nearest scaffold has drawer then only it will open it.

      // hiding current snackbar and showing new snackbar message with undo action.
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       '${product.title} Added to the cart!',
      //     ),
      //     duration: Duration(seconds: 2),
      //     action: SnackBarAction(
      //       label: 'UNDO',
      //       onPressed: () {
      //         cart.removeItem(product.id);
      //       },
      //     ),
      //   ),
      // );
    }
  }

  void toggleFavoriteStatus(var product, var authData, var context) async {
    print('favorite status BEFORE : ${product.isFavorite}');

    try {
      print('inside try : ${authData.token} ${authData.userId}');
      await product.toggleFavoriteStatus(
        authData.token as String,
        authData.userId as String,
      );
      print('succedd favorite try block');
    } catch (error) {
      print('entered favorite catch block');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.error,
                color: Theme.of(context).errorColor,
              ),
              Text(
                'Something went wrong!\nCould not favorite ${product.title}.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
      );
      print('ERROR OCCURRED WHILE FAVORATING : $error');
    }
    print('favorite status AFTER : ${product.isFavorite}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final authData = Provider.of<Auth>(context, listen: false);
    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen:
          false, //dont  rebuild this widget when any data changes. => listen=false. even if notify listeners is called this data will not be changed as if we are  just adding simply a new item will not change the data of the current item.
    ).findById(productId);
    var isFavorite = loadedProduct.isFavorite;
    // Provider.of<ProductsProvider>(context).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SlideTransition(
        position: _slideAnimation,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: fabIsVisible ? 1 : 0,
          child: Container(
            margin: EdgeInsets.only(bottom: 30),
            padding: EdgeInsets.symmetric(horizontal: 20),
            // alignment: Alignment.bottomCenter,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cart.isPresentInCart(loadedProduct.id)
                          ? lighten(Theme.of(context).colorScheme.secondary)
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      setState(() {
                        toggleItemInCart(loadedProduct, cart, context);
                      });
                    },
                    icon: cart.isPresentInCart(loadedProduct.id)
                        ? Icon(Icons.shopping_cart)
                        : Icon(Icons.shopping_cart_outlined),
                    label: cart.isPresentInCart(loadedProduct.id)
                        ? Text('Remove from cart')
                        : Text('Add to cart'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        print('Favorite button pressed.');
                        setState(() {
                          toggleFavoriteStatus(
                              loadedProduct, authData, context);
                        });
                      },
                      color: Colors.red,
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height / 3,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  // color: Colors.black54,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.withOpacity(0.1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Text(
                  loadedProduct.title,
                  textAlign: TextAlign.center,
                ),
              ),
              background: Hero(
                transitionOnUserGestures: true,
                tag: loadedProduct.id,
                child: FadeInImage.assetNetwork(
                  image: loadedProduct.imageUrl,
                  placeholder: 'assets/images/product-placeholder.png',
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/error-placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // expandedHeight: 300,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  '\$${loadedProduct.price}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true, //wraps in new line if there is no space.
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange,
                        Colors.deepOrange.withOpacity(0),
                      ],
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter,
                    ),
                    // color: Colors.purple.withOpacity(0.7),
                  ),
                  child: Text(
                    'Seller : ${loadedProduct.seller}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    softWrap: true, //wraps in new line if there is no space.
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                //test sized box :
                // SizedBox(
                //   height: 800,
                // )
              ],
            ),
          ),
        ], //scrollable areas on screens.

        //NO LONGER NEEDED
        // child: Column(
        //   children: [
        //     Container(
        //       height: MediaQuery.of(context).size.height / 3,
        //       width: double.infinity,
        //       child: Hero(
        //         transitionOnUserGestures: true,
        //         tag: loadedProduct.id,
        //         child: FadeInImage.assetNetwork(
        //           image: loadedProduct.imageUrl,
        //           placeholder: 'assets/images/product-placeholder.png',
        //           imageErrorBuilder: (context, error, stackTrace) =>
        //               Image.asset('assets/images/error-placeholder.png'),
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}

// OLDER IMPLEMENTATION :
/*
child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              child: Hero(
                transitionOnUserGestures: true,
                tag: loadedProduct.id,
                child: FadeInImage.assetNetwork(
                  image: loadedProduct.imageUrl,
                  placeholder: 'assets/images/product-placeholder.png',
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/error-placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true, //wraps in new line if there is no space.
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                'Seller : ${loadedProduct.seller}',
                textAlign: TextAlign.center,
                softWrap: true, //wraps in new line if there is no space.
              ),
            ),
          ],
        ),
*/


/*
bottom buttons : 
Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                            // primary: Colors.amber,
                          ),
                          onPressed: () {
                            print('Add to cart pressed');
                          },
                          icon: Icon(Icons.shopping_cart_outlined),
                          label: Text('Add to cart'),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          print('Favorite button pressed.');
                        },
                        color: Colors.red,
                        icon: Icon(Icons.favorite),
                      ),
                    ],
                  ),
                ),
*/