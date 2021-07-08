import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen:
          false, //dont  rebuild this widget when any data changes. => listen=false. even if notify listeners is called this data will not be changed as if we are  just adding simply a new item will not change the data of the current item.
    ).findById(productId);
    // Provider.of<ProductsProvider>(context).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height / 3,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                  padding: EdgeInsets.all(3),
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
                  child: Text(loadedProduct.title)),
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
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    'Seller : ${loadedProduct.seller}',
                    textAlign: TextAlign.center,
                    softWrap: true, //wraps in new line if there is no space.
                  ),
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
