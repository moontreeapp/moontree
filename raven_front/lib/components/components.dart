//import 'package:flutter/material.dart';

import 'package:raven_front/components/styles/decorations.dart';

import 'alerts.dart';
import 'buttons.dart';
import 'headers.dart';
import 'icons.dart';
import 'empty.dart';
import 'routes.dart';
import 'status.dart';
import 'text.dart';
import 'styles/buttons.dart';

class components {
  static final Styles styles = Styles();

  static final AlertComponents alerts = AlertComponents();
  static final ButtonComponents buttons = ButtonComponents();
  static final IconComponents icons = IconComponents();
  static final TextComponents text = TextComponents();
  static final AppLifecycleReactor status = AppLifecycleReactor();
  static final EmptyComponents empty = EmptyComponents();
  static final HeaderComponents headers = HeaderComponents();
  //static final RouteObserver<PageRoute> routeObserver =
  //    RouteObserver<PageRoute>();
  // handled by navigator
  static final RouteStack navigator = RouteStack();
}

class Styles {
  final ButtonStyleComponents buttons = ButtonStyleComponents();
  final DecorationComponents decorations = DecorationComponents();
}
