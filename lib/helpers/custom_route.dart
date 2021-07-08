import 'package:flutter/material.dart';

class CustomRoute extends MaterialPageRoute {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);
    if (settings.name == '/') {
      return child; //if the landing page is the first page then I don't want to animate it so I am just returning it as it is.
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}


class CustomPageTransitionBuilder extends PageTransitionsBuilder{
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);
    if (route.settings.name == '/') {
      return child; //if the landing page is the first page then I don't want to animate it so I am just returning it as it is.
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}