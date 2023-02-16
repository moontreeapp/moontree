import 'package:flutter/material.dart';
import 'buttons.dart';
import 'containers.dart';
import 'cubits.dart';
import 'icons.dart';
import 'empty.dart';
import 'routes.dart';
import 'status.dart';
import 'text.dart';
import 'loading.dart';
import 'message.dart';
import 'shape.dart';
import 'page.dart';

const ButtonComponents buttons = ButtonComponents();
const ContainerComponents containers = ContainerComponents();
final IconComponents icons = IconComponents();
const TextComponents text = TextComponents();
const AppLifecycleReactor status = AppLifecycleReactor();
const EmptyComponents empty = EmptyComponents();
final RouteStack routes = RouteStack();
final GlobalCubits cubits = GlobalCubits();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
const LoadingComponents loading = LoadingComponents();
const MessageComponents message = MessageComponents();
const PageComponents page = PageComponents();
const ShapeComponents shape = ShapeComponents();

//static final RouteObserver<PageRoute> routeObserver =
//    RouteObserver<PageRoute>();
// handled by routes