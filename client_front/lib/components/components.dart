//import 'package:flutter/material.dart';

// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:client_front/components/styles/decorations.dart';

import 'buttons.dart';
import 'containers.dart';
import 'icons.dart';
import 'empty.dart';
import 'routes.dart';
import 'status.dart';
import 'text.dart';
import 'loading.dart';
import 'message.dart';
import 'shape.dart';
import 'page.dart';
import 'styles/buttons.dart';

// ignore: avoid_classes_with_only_static_members
class components {
  static final Styles styles = Styles();

  static final ButtonComponents buttons = ButtonComponents();
  static final ContainerComponents containers = ContainerComponents();
  static final IconComponents icons = IconComponents();
  static final TextComponents text = TextComponents();
  static const AppLifecycleReactor status = AppLifecycleReactor();
  static final EmptyComponents empty = EmptyComponents();
  //static final RouteObserver<PageRoute> routeObserver =
  //    RouteObserver<PageRoute>();
  // handled by navigator
  static final RouteStack navigator = RouteStack();
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  static final LoadingComponents loading = LoadingComponents();
  static final MessageComponents message = MessageComponents();
  static final PageComponents page = PageComponents();
  static final ShapeComponents shape = ShapeComponents();
}

class Styles {
  final ButtonStyleComponents buttons = ButtonStyleComponents();
  final DecorationComponents decorations = DecorationComponents();
}
