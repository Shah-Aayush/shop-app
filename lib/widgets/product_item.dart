import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart_provider.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // final double price;

  // ProductItem(this.id, this.title, this.imageUrl, this.price);

  @override
  Widget build(BuildContext context) {
    // final _key = new GlobalKey();

    final product = Provider.of<Product>(
      context,
      listen: false,
    ); //if we provide listen=false here then it will not change the icon or reflect the changes.
    //we can also apply changes with wrapping those widgets which requires to change in CONSUMER widget.
    // print('product rebuilds.');
    final cart = Provider.of<CartProvider>(context,
        listen:
            false); //this is only for adding new items to the cart. so we are not changing the cart screen now. the changes will be reflect ed when we open cart section.
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (ctx) => ProductDetailScreen(title),
            //   ),
            // );
          },
          child: Hero(
            transitionOnUserGestures: true,
            tag: product.id,
            child: FadeInImage.assetNetwork(
              image: product.imageUrl,
              placeholder: 'assets/images/product-placeholder.png',
              imageErrorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/images/error-placeholder.png'),

              fit: BoxFit.cover, //will resize and crop the image
            ),
          ),
        ),
        header: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            // builder: (context, product, child) => IconButton(  //when we use child arugment.
            builder: (ctx, product, _) => IconButton(
              //not using child so ignoring.
              color: Theme.of(context).colorScheme.secondary,
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavoriteStatus();
              },
              //here we can use child arugment which will not rebuild/changes but as we don't need it we will not.
            ),
            // child: Text('Never Changes!'), //Here this child argument is the argument which will not changes when we use it in that builder function.
          ),
          backgroundColor: Colors
              .black87, //color with opacity -> More the numbers, less the tranparency
          title: Text(
            '\$${product.price}',
            textAlign: TextAlign.center,
          ),
          // trailing: Consumer<CartProvider>(
          //   builder: (ctx, prod, _) => Tooltip(
          //     key: _key,
          //     child: IconButton(
          //       color: Theme.of(context).accentColor,
          //       icon: Icon(Icons.shopping_cart),
          //       onPressed: () {
          //         cart.addItem(product.id, product.price, product.title);
          //         final dynamic tooltip = _key.currentState;
          //         tooltip.ensureTooltipVisible();
          //         print(
          //             'product quantity : ${cart.items[product.id]} ${cart.getQuantity(product.id)}');
          //         // print('added to cart');
          //       },
          //     ),
          //     message: cart.getQuantity(product.id).toString(),
          //   ),
          trailing: Consumer<CartProvider>(
            builder: (ctx, prod, _) => IconButton(
              color: Theme.of(context).colorScheme.secondary,
              icon: cart.isPresentInCart(product.id)
                  ? Icon(Icons.shopping_cart)
                  : Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                if (cart.isPresentInCart(product.id)) {
                  cart.removeItem(product.id);
                } else {
                  cart.addItem(product.id, product.price, product.title);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}


/*

//ORIGINAL IMAGE WITH DIRECT NETWORK : 
 child: Image.network(
          imageUrl,

          fit: BoxFit.cover, //fits the entire container /covers it.
          // fit: BoxFit.fill, //fills the entire container.
          // fit: BoxFit.fitWidth, //fills the width of the container.
        ),
*/

/*
old approach without consumer :
final product = Provider.of<Product>(
        context); //if we provide listen=false here then it will not change the icon or reflect the changes.
    //we can also apply changes with wrapping those widgets which requires to change in CONSUMER widget.
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (ctx) => ProductDetailScreen(title),
            //   ),
            // );
          },
          child: FadeInImage.assetNetwork(
            image: product.imageUrl,
            placeholder: 'assets/images/product-placeholder.png',
            imageErrorBuilder: (context, error, stackTrace) =>
                Image.asset('assets/images/error-placeholder.png'),

            fit: BoxFit.cover, //will resize and crop the image
          ),
        ),
        header: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
        footer: GridTileBar(
          leading: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              product.toggleFavoriteStatus();
            },
          ),
          backgroundColor: Colors
              .black87, //color with opacity -> More the numbers, less the tranparency
          title: Text(
            '\$${product.price}',
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ),
      ),
    ); 
*/

/*
difference between use of the Consumer widget and Provider.of<Product>(context) :  
Whenever we use provider.of(context) then entire build method will be run but when we use consumer<product> then the  widgets which are wrapped using it, only run. so consumer can be improve the  performance of our app when we have to update just fewer widgets.

CURRENT APPLICATION IS mixing of both. we applied listen=false and also applied consumer to only favorite widget so that only that part of the app will be changed.  
*/

/*
WRAPPING ENTIRE WIDGET INOT CONSUMER : 
return Consumer<Product>(
      builder: (context, product, child) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (ctx) => ProductDetailScreen(title),
              //   ),
              // );
            },
            child: FadeInImage.assetNetwork(
              image: product.imageUrl,
              placeholder: 'assets/images/product-placeholder.png',
              imageErrorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/images/error-placeholder.png'),

              fit: BoxFit.cover, //will resize and crop the image
            ),
          ),
          header: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
          ),
          footer: GridTileBar(
            leading: IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavoriteStatus();
              },
            ),
            backgroundColor: Colors
                .black87, //color with opacity -> More the numbers, less the tranparency
            title: Text(
              '\$${product.price}',
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(Icons.shopping_cart),
              onPressed: () {},
            ),
          ),
        ),
      ),
      // child: ,
    );
*/