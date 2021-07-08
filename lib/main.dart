import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/animated_auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/auth.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/orders_provider.dart';
import './screens/user_products_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //when we want to listen to multiple providers.
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          update: (ctx, auth, previousProducts) =>
              previousProducts!..updateUser(auth.token, auth.userId),
          create: (ctx) => ProductsProvider(null, null, []),
        ),

        //older approach which is not working after auto authentication user.
        // ChangeNotifierProxyProvider<Auth, ProductsProvider>(
        //   update: (ctx, auth, previousProducts) => ProductsProvider(
        //     auth.token,
        //     auth.userId,
        //     previousProducts == null ? [] : previousProducts.items,
        //     // auth.token as String,
        //     // auth.userId as String,
        //     // previousProducts == null ? [] : previousProducts.items,
        //   ), //depends on another provider
        //   create: (ctx) => ProductsProvider(null, null, []),
        // ),
        // ChangeNotifierProvider(
        //   create: (ctx) => ProductsProvider(),
        // ),

        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, OrdersProviders>(
          update: (ctx, auth, previousOrders) => OrdersProviders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
          create: (ctx) => OrdersProviders(null, null, []),
        ),
        // ChangeNotifierProvider(
        //   create: (ctx) => OrdersProviders(),
        // ),
      ],
      child: Consumer<Auth>(
        //only this part will be rebuild. so whenever that AUTH object changes, this material app widget will be rebuild.
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(secondary: Colors.deepOrange),
            fontFamily: 'Lato',
            //Page transition setting by default :
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : auth.isAuth
                              ? ProductsOverviewScreen()
                              : AnimatedAuthScreen(),
                ),
          // home: AuthScreen(),
          // home: ProductsOverviewScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('MyShop'),
//       ),
//       body: Center(
//         child: Text('Let\'s build a shop!'),
//       ),
//     );
//   }
// }

/*
CHANGE NOTIFIER BEFORE : 
ChangeNotifierProvider(
      //this should be added in the parent widgets of where we want to listen changes. so here we want to listen changes in everywhere so that we are adding this in main file.
      create: (ctx) => ProductsProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
        },
      ),
    );
  }
*/

/*
Change provider with single provider : 
return ChangeNotifierProvider(
      //this should be added in the parent widgets of where we want to listen changes. so here we want to listen changes in everywhere so that we are adding this in main file.
      create: (_) =>  ProductsProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
        },
      ),
    );
*/

/*
// NEW VERSION OF HTTPS : 
  final url = Uri.parse('https://flutter-update.firebaseio.com/products.json')
  http.post(url, ...)
// Alternatively, you can also use this syntax:
  final url = Uri.https('flutter-update.firebaseio.com', '/products.json')
  http.post(url, ...)
*/
