import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/string.dart';

class RouteStack extends NavigatorObserver {
  List<Route<dynamic>> routeStack = [];
  BuildContext? routeContext;
  BuildContext? scaffoldContext;
  TabController? tabController;
  bool isSnackbarActive = false;

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.add(route);
    routeContext = route.navigator?.context;
    streams.app.page.add(conformName(route.settings.name));
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    routeContext = routeStack.last.navigator?.context;
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    routeStack.removeLast();
    routeContext = routeStack.last.navigator?.context;
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    routeStack.removeLast();
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    routeContext = routeStack.last.navigator?.context;
    streams.app.page.add(conformName(routeStack.last.settings.name));
  }

  String conformName(String? name) =>
      handleHome(name?.split('/').last.toTitleCase() ?? streams.app.page.value);

  String handleHome(String name) => name == 'Home' ? 'Wallet' : name;
}
