import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({
    required this.child,
  }) : super(
    transitionDuration: Duration(seconds: 1),
    reverseTransitionDuration: Duration(seconds: 1),
    pageBuilder: (context, anim, secondaryAnim) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> anim,
          Animation<double> secondaryAnim, Widget child) =>
      FadeThroughTransition(
          child: child, animation: anim, secondaryAnimation: secondaryAnim);
}
