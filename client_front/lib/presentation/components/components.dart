import 'package:flutter/material.dart';
import 'buttons.dart';
import 'cubits.dart';
import 'icons.dart';
import 'empty.dart';
import 'routes.dart';
import 'status.dart';
import 'text.dart';
import 'loading.dart';
import 'message.dart';

const ButtonComponents buttons = ButtonComponents();
final IconComponents icons = IconComponents();
const TextComponents text = TextComponents();
const AppLifecycleReactor status = AppLifecycleReactor();
const EmptyComponents empty = EmptyComponents();
final RouteStack routes = RouteStack();
final GlobalCubits cubits = GlobalCubits();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
const LoadingComponents loading = LoadingComponents();
const MessageComponents message = MessageComponents();


//static final RouteObserver<PageRoute> routeObserver =
//    RouteObserver<PageRoute>();
// handled by routes