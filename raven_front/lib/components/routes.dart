import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/string.dart';

class RouteStack extends NavigatorObserver {
  List<Route<dynamic>> routeStack = [];

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.add(route);
    streams.app.page.add(conformName(route.settings.name));
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    routeStack.removeLast();
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    routeStack.removeLast();
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  String conformName(String? name) {
    return name?.split('/').last.toTitleCase() ?? 'unknown';
  }
}
