//import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:raven_front/components/styles/decorations.dart';

import 'buttons.dart';
import 'headers.dart';
import 'icons.dart';
import 'empty.dart';
import 'routes.dart';
import 'status.dart';
import 'text.dart';
import 'loading.dart';
import 'styles/buttons.dart';

class components {
  static final Styles styles = Styles();

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
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  static final LoadingComponents loading = LoadingComponents();
}

class Styles {
  final ButtonStyleComponents buttons = ButtonStyleComponents();
  final DecorationComponents decorations = DecorationComponents();
}
