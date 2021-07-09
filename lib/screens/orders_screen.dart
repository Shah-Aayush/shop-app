import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/orders_provider.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _orderFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<OrdersProviders>(context, listen: false)
        .fetchAndSetOrders();
  }

  @override
  void initState() {
    _orderFuture = _obtainOrdersFuture();
    super.initState();
  }

  //IF WE HAVE STATEFUL WIDGET, THEN WE SHOULD DO THIS : [saving future in variable and initializing in initstate.]
  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<OrdersProviders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        //This approach will work absolutely fine in this app and in particular this screen as we don't have additional state changing logic! but what if we have, then we can have problems of rebuilding widgets and sending again http requests.
        future: _orderFuture,
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
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
                        'Fetching orders...',
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (dataSnapShot.error != null) {
            //do error handling stuff...
            return Center(child: Text('ERROR :)'));
          } else {
            return Consumer<OrdersProviders>(builder: (ctx, ordersData, child) {
              if (ordersData.orders.length == 0) {
                return Center(
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
                        Lottie.asset('./assets/animations/empty_box.json',
                            repeat: false,
                            height: MediaQuery.of(context).size.height / 3),
                      Text(
                        'Not placed any orders yet.',
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Start ordering some!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: ordersData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
                );
              }
            });
          }
        },
      ),
    );
  }
}


/*
//OLD IMPLEMENTATION WITHOUT FUTURE BUILDER : 
class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    //New implementation :
    super.initState();

    _isLoading = true;

    Provider.of<OrdersProviders>(context, listen: false)
        .fetchAndSetOrders()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    //older implementation :
    //we should not turn this init function to async as by default it is not async.
    // super.initState();
    // Future.delayed(Duration.zero).then((_) async {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //   await Provider.of<OrdersProviders>(context, listen: false)
    //       .fetchAndSetOrders();
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }); //this is queued to the end of the execution.
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<OrdersProviders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: (_isLoading)
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
                        width: 400,
                        height: 400,
                      ),
                      Text(
                        'Fetching orders...',
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
          : (ordersData.orders.length == 0)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        './assets/animations/empty_box.json',
                        repeat: false,
                      ),
                      Text(
                        'Not placed any orders yet.',
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Start ordering some!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: ordersData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
                ),
    );
  }
}
*/


/*
//WITH STATEFUL WIDGET : 
class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<OrdersProviders>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          //This approach will work absolutely fine in this app and in particular this screen as we don't have additional state changing logic! but what if we have, then we can have problems of rebuilding widgets and sending again http requests.
            future: Provider.of<OrdersProviders>(context, listen: false)
                .fetchAndSetOrders(),
            builder: (ctx, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/loading_paperplane.json',
                            width: 400,
                            height: 400,
                          ),
                          Text(
                            'Fetching orders...',
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (dataSnapShot.error != null) {
                //do error handling stuff...
                return Center(child: Text('ERROR :)'));
              } else {
                return Consumer<OrdersProviders>(
                    builder: (ctx, ordersData, child) {
                  if (ordersData.orders.length == 0) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            './assets/animations/empty_box.json',
                            repeat: false,
                          ),
                          Text(
                            'Not placed any orders yet.',
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            'Start ordering some!',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: ordersData.orders.length,
                      itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
                    );
                  }
                });
              }
            })
        // (_isLoading)
        //     ? SingleChildScrollView(
        //         child: Center(
        //           child: Padding(
        //             padding: EdgeInsets.all(10),
        //             child: Column(
        //               mainAxisSize: MainAxisSize.min,
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Lottie.asset(
        //                   'assets/animations/loading_paperplane.json',
        //                   width: 400,
        //                   height: 400,
        //                 ),
        //                 Text(
        //                   'Fetching orders...',
        //                   style: TextStyle(
        //                     fontSize: 30,
        //                     color: Theme.of(context).primaryColor,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       )
        //     : (ordersData.orders.length == 0)
        //         ? Center(
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Lottie.asset(
        //                   './assets/animations/empty_box.json',
        //                   repeat: false,
        //                 ),
        //                 Text(
        //                   'Not placed any orders yet.',
        //                   style: TextStyle(
        //                     fontSize: 30,
        //                     color: Theme.of(context).primaryColor,
        //                   ),
        //                 ),
        //                 Text(
        //                   'Start ordering some!',
        //                   style: TextStyle(
        //                     fontSize: 20,
        //                     color: Theme.of(context).colorScheme.secondary,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           )
        //         : ListView.builder(
        //             itemCount: ordersData.orders.length,
        //             itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
        //           ),
        );
  }
}
*/