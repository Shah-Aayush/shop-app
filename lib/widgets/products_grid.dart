import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import './product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(
        context); //here we don't setted up the listen argument as false  because adding new item will impact the grid view , we have to display it in the grid view so we have to rebuild the grid view so  we are not adding the listen argument in here.
    final products = showFavs ? productsData.favoriteItems : productsData.items;

    if (showFavs && products.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              './assets/animations/empty_box.json',
              repeat: false,
            ),
            Text(
              'You have no favorites yet.',
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Start adding some!',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(
            // products[i].id,
            // products[i].title,
            // products[i].imageUrl,
            // products[i].price,
            ), //defines content of each grid child
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent:
            400, //every child which spans crossaxis width. for screen size 300 : it will contain only  1 child but for screen size 500 : it will contain 2 children.
        childAspectRatio: 3 / 2, //shows that  for 200 width, I want 300 height.
        crossAxisSpacing: 20, //spacing between children
        mainAxisSpacing: 20, //spacing between children
      ),
    );
  }
}


/*Item builder before : 

itemBuilder: (ctx, i) => ChangeNotifierProvider(
        create: (c) => products[i],
        child: ProductItem(
            // products[i].id,
            // products[i].title,
            // products[i].imageUrl,
            // products[i].price,
            ), //defines content of each grid child
      ),

==> Difference between ChangeNotifierProvider and ChangeNotifierProvider.value is that if we are using listview or gridview then we should use .value method as this builder function desposes and recycles everythin which are not visible to screen. so it can cause errors. using value can save us from that.
==> Also when we are not using the values from builder method in that particular class where we providing it, then we should use value method as we are not using anything important in main method about products, we are using .value method.
==>FINAL VERDICT : When you are creating a new instance of the object like we do in main.dart, we have to use simple builder approach to avoid bugs. but when we are RE-USING the previously made object than we have to use value method.
 
==>NOTE : Flutter cleans the data whenever new screen is added on top of the stack. but providers data cannot clean by flutter. That data should be cleaned by us whenever we visit new screen. Fortunately, here chagneNotifierProvider will clean up that data for us.
*/