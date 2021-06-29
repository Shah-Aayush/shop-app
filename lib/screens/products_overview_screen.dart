import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../providers/products_provider.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart_provider.dart';
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
      body: ProductsGrid(_showOnlyFavorites),
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