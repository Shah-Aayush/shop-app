import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/orders_provider.dart';
import '../providers/cart_provider.dart'
    show
        CartProvider; //if we have multiple similar class names from which we only want to import something then we do this.
//if we have no choice then we can also use as argument. like import '...' as cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: (cart.itemCount == 0)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    './assets/animations/empty_box.json',
                    repeat: false,
                  ),
                  Text(
                    'Not added any items yet.',
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
            )
          : Column(
              children: [
                Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Spacer(), //acquire spaces which is remaining.
                        Chip(
                          label: Text(
                            '\$${double.parse((cart.totalAmount).toStringAsFixed(2))}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6!
                                  .color,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<OrdersProviders>(context,
                                    listen:
                                        false) //listen false because we don't want to change this cart screen on order placing.
                                .addOrder(cart.items.values.toList(),
                                    cart.totalAmount);
                            cart.clearCart();
                          },
                          child: Text(
                            'ORDER NOW',
                          ),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, i) => CartItem(
                      cart.items.values.toList()[i].id,
                      cart.items.values.toList()[i].price,
                      cart.items.values.toList()[i].quantity,
                      cart.items.values.toList()[i].title,
                      //this values will throw errors as they are iterables
                      // cart.items[i]!.id,
                      // cart.items[i]!.price,
                      // cart.items[i]!.quantity,
                      // cart.items[i]!.title,
                    ),
                    itemCount: cart.itemCount,
                  ),
                ),
              ],
            ),
    );
  }
}
