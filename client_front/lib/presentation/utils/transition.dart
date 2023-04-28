import 'package:flutter/material.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;

class MyRoute extends MaterialPageRoute {
  MyRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => animation.fadeDuration;
}
