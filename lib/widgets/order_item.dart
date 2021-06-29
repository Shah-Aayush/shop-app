import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_item.dart' as ord;
// import '../providers/orders_provider.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
            subtitle: Text(
                'Ordered on ${DateFormat('hh:mm a, dd/MM/yyyy').format(widget.order.dateTime)}'),
            trailing: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    if (_expanded) {
                      _controller..reverse(from: 0.5);
                    } else {
                      _controller..forward(from: 0.0);
                    }
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
          ),
          if (_expanded)
            Scrollbar(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: math.min(widget.order.products.length * 20.0 + 20,
                    100), //picks the minimum value among provided values
                child: ListView(
                  children: widget.order.products
                      .map(
                        (product) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${product.quantity} x \$${product.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            )
        ],
      ),
    );
  }
}


/*
trailing button trials : 
// trailing: AnimatedBuilder(
            //   builder: (_, child) {
            //     return Transform.rotate(
            //       angle: _controller.value * 2 * math.pi,
            //       // angle: _expanded ? 0 : 180 * math.pi / 180,
            //       child: IconButton(
            //         icon: Icon(Icons.expand_less),
            //         onPressed: () {
            //           setState(() {
            //             _expanded = !_expanded;
            //           });
            //         },
            //       ),
            //     );
            //   },
            //   animation: _controller,
            //   // child: ,
            //   // duration: Duration(seconds: 1),
            // ),

            // trailing: IconButton(
            //   icon: AnimatedContainer(
            //       duration: Duration(seconds: 3),
            //       child: Transform.rotate(
            //           angle: _expanded ? 0 : 180 * math.pi / 180,
            //           child: Icon(Icons.expand_less))),
            //   // icon:
            //   //     _expanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
            //   onPressed: () {
            //     setState(() {
            //       _expanded = !_expanded;
            //     });
            //   },
            // ),
*/