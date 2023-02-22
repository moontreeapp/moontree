import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';

class RouteStack extends NavigatorObserver {
  RouteStack();
  List<Route<dynamic>> routeStack = <Route<dynamic>>[];
  BuildContext? routeContext;
  BuildContext? scaffoldContext;
  BuildContext? mainContext;
  TabController? tabController;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey appKey = GlobalKey();

  bool nameIsInStack(String name) =>
      routeStack.map((Route<dynamic> e) => e.settings.name).contains(name);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.add(route);
    routeContext ??= route.navigator?.context;
    // dismiss the snackbar in case there is one.
    if (previousRoute?.settings.name == '/home') {
      ScaffoldMessenger.of(routeContext!).clearSnackBars();
    }

    /// moved to sailor
    //streams.app.path.add(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;

    /// moved to sailor
    //streams.app.path
    //    .add(routeStack.isEmpty ? null : routeStack.last.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;

    /// moved to sailor
    //streams.app.path
    //    .add(routeStack.isEmpty ? null : routeStack.last.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;

    /// moved to sailor
    //streams.app.path
    //    .add(routeStack.isEmpty ? null : routeStack.last.settings.name);
  }
}
