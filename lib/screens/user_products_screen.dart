import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding user products screen...');
    // final productsData = Provider.of<ProductsProvider>(context, listen: false);
    // final productsData = Provider.of<ProductsProvider>(
    //     context); //before we didn't added listen:false.
    // print('manage products pressed.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName,
                  arguments:
                      -1); //we used pushNamed here so that we also can get back to the original users product page. if we use pushReplacement then we cannot get back.
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
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
                          'Fetching your products...',
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
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<ProductsProvider>(
                  builder: (ctx, productsData, _) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: (productsData.items.length == 0)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (MediaQuery.of(context).orientation ==
                                    Orientation.portrait)
                                  Lottie.asset(
                                    './assets/animations/empty_box.json',
                                    repeat: false,
                                  ),
                                if (MediaQuery.of(context).orientation ==
                                    Orientation.landscape)
                                  Lottie.asset(
                                      './assets/animations/empty_box.json',
                                      repeat: false,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3),
                                Text(
                                  'Not added any products yet.',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  'Start adding some!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
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
                ),
              ),
      ),
    );
  }
}
