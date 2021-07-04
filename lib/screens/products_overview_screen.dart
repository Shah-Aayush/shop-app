import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../screens/cart_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts();  //this will not work as it requires context and its listen is set to true by default.
    // Provider.of<ProductsProvider>(context,listen:false).fetchAndSetProducts();  //this will work as we set the listen is true.

    //this is one of the working approach //this is kind of a heck!!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer =
    //     Provider.of<ProductsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              print(selectedValue);
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  // productsContainer.showFavoritesOnly();
                  _showOnlyFavorites = true;
                } else {
                  // productsContainer.showAll();
                  _showOnlyFavorites = false;
                }
              });
            },
          ),
          Consumer<CartProvider>(
            builder: (_, cartData, ch) => Badge(
              child: ch as Widget,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              //this wont be rebuild as it is defined outside of the builder method.
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/loading_paperplane.json',
                        width: MediaQuery.of(context).size.width / 1.5,
                        // height: 400,
                      ),
                      Text(
                        'Fetching products...',
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
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}




/*
// WITH FIXED CROSS AXIS COUNT
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //columns count
          childAspectRatio: 3 / 2, //width height ratio
          crossAxisSpacing: 10, //spacing b/w columns
          mainAxisSpacing: 10, //spacing b/w rows
        ), //defines structure of each grid child

// WITH MAX CROSS AXIS EXTENT
SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent:
            200, //every child which spans crossaxis width. for screen size 300 : it will contain only  1 child but for screen size 500 : it will contain 2 children.
        childAspectRatio: 3 / 2, //shows that  for 200 width, I want 300 height.
        crossAxisSpacing: 20, //spacing between children
        mainAxisSpacing: 20, //spacing between children
      )
*/