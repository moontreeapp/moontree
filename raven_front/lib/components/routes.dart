import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';

class RouteStack extends NavigatorObserver {
  List<Route<dynamic>> routeStack = [];
  BuildContext? routeContext;
  BuildContext? scaffoldContext;
  TabController? tabController;
  bool isSnackbarActive = false;

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.add(route);
    routeContext = route.navigator?.context;
    streams.app.page.add(conformName(route.settings.name));
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;
    streams.app.page.add(
        conformName(routeStack.isEmpty ? null : routeStack.last.settings.name));
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;
    streams.app.page.add(
        conformName(routeStack.isEmpty ? null : routeStack.last.settings.name));
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;
    streams.app.page.add(
        conformName(routeStack.isEmpty ? null : routeStack.last.settings.name));
  }

  String conformName(String? name) =>
      name?.split('/').last.toTitleCase() ?? streams.app.page.value;
}
