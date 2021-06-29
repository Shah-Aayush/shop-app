import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cart.removeItem(id);
      },
      key: ValueKey(id),
      background: Container(
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).errorColor,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                  padding: EdgeInsets.all(3),
                  child: FittedBox(child: Text('\$$price'))),
            ),
            title: Text(title),
            subtitle: Text(
                'Total : \$${double.parse((price * quantity).toStringAsFixed(2))}'),
            // trailing: Text('$quantity x'),
            // trailing: Wrap(
            //   spacing: 2,
            //   children: [
            //     Spacer(),
            // TextButton(onPressed: () {}, child: Text('-')),
            // TextButton(onPressed: () {}, child: Text('+')),
            //   ],
            // ),
            trailing: FittedBox(
              fit: BoxFit.fill,
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: 25,
                      child: TextButton(
                          onPressed: () {
                            cart.decreaseQuantity(id);
                            if (quantity == 1) {
                              cart.removeItem(id);
                            }
                          },
                          child: Text(
                            '-',
                            textAlign: TextAlign.center,
                          ))),
                  SizedBox(
                    width: 5,
                  ),
                  Text('$quantity'),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                      width: 25,
                      child: TextButton(
                          onPressed: () {
                            cart.increaseQuantity(id);
                          },
                          child: Text(
                            '+',
                            textAlign: TextAlign.center,
                          ))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
