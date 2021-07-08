import 'dart:math' as math;

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';

import '../models/order_item.dart' as ord;
// import '../providers/orders_provider.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with TickerProviderStateMixin {
  Key _keyCard = GlobalKey();

  late AnimationController _controller;

  late AnimationController _containerController;
  late Animation<Size> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );

    _containerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    //vsync is a argument where we give an animation controller a pointer to a widget which it will watch when it is visible on screen to the user.
    //this require a TickerProviderStateMixin or SingleTickerProviderStateMixin.

    print('when accessing cardsize : $cardSize');
    _heightAnimation = Tween<Size>(
      begin: Size(
        double.infinity,
        cardSize.toDouble() - 5,
      ),
      end: Size(
        double.infinity,
        cardSize.toDouble() + setHeight(),
      ),
    ).animate(
        CurvedAnimation(parent: _containerController, curve: Curves.linear));
    _heightAnimation.addListener(() => setState(() {}));

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _containerController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset(0, 0),
    ).animate(
        CurvedAnimation(parent: _containerController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _containerController.dispose();
  }

  var _expanded = false;

  var cardSize = 80;

  double setHeight() {
    return math.min(widget.order.products.length * 20.0 + 20, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Container(
          height: (!_expanded) ? _heightAnimation.value.height : null,
          child: Column(
            children: [
              MeasureSize(
                onChange: (size) {
                  // setState(() {
                  //   cardSize = size.width.toInt();
                  // });
                  cardSize = size.width.toInt();
                  print('### new card size is : $cardSize.');
                },
                child: ListTile(
                  key: _keyCard,
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
                            _expanded = !_expanded;
                            _controller..reverse(from: 0.5);
                            _containerController.reverse();
                          } else {
                            // Future.delayed(const Duration(milliseconds: 300), () {
                            _expanded = !_expanded;
                            // });
                            _controller..forward(from: 0.0);
                            _containerController.forward();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (_expanded)
                Scrollbar(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    height: setHeight(),
                    // height: math.min(widget.order.products.length * 20.0 + 20,
                    //     100), //picks the minimum value among provided values
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ListView(
                          children: widget.order.products
                              .map(
                                (product) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                    ),
                  ),
                )
            ],
          ),
        ),
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

//FOR MEASURING SIZE OF THE WIDGET :
typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size oldSize = Size.zero;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
