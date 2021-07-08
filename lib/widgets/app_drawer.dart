import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';
import '../helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {
  String greeting() {
    var hour = DateTime.now().hour;

    if (hour > 5 && hour < 12) {
      return 'Morning';
    }
    if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    }
    if (hour >= 17 && hour < 23) {
      return 'Evening';
    }
    return 'Night';
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(35)),
      child: Drawer(
        child: Column(
          children: [
            AppBar(
              title: Text('Good ${greeting()} ${authData.displayName}!'),
              // title: Text('Shopping is my cardio !'),
              automaticallyImplyLeading:
                  false, //it will never add back button here.
            ),
            Divider(), //horizontal line
            ListTile(
              leading: Icon(Icons.shop),
              title: Text('Shop'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Orders'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(OrdersScreen.routeName);
                // Navigator.of(context).pushReplacement(
                //   CustomRoute(
                //     builder: (ctx) => OrdersScreen(),
                //   ),
                // );
              },
            ),
            Divider(), //horizontal line
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserProductsScreen.routeName);
              },
            ),
            Divider(), //horizontal line
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop(); //close drawer before logging out!
                Navigator.of(context).pushReplacementNamed('/');

                authData.logout();
                // Navigator.of(context)
                //     .pushReplacementNamed(UserProductsScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
