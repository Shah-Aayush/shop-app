import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    print('manage products pressed.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen
                  .routeName); //we used pushNamed here so that we also can get back to the original users product page. if we use pushReplacement then we cannot get back.
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          // itemBuilder: (_, i) => Text('simple text'),
          itemBuilder: (_, i) => Column(children: [
            UserProductItem(
              productsData.items[i].id,
              productsData.items[i].title,
              productsData.items[i].imageUrl,
            ),
            Divider(),
          ]),
          itemCount: productsData.items.length,
        ),
      ),
    );
  }
}
