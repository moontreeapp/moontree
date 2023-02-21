import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
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
    streams.app.page.add(conformName(route.settings.name));
    print('streams.app.page.value ${streams.app.page.value}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;
    streams.app.page.add(
        conformName(routeStack.isEmpty ? null : routeStack.last.settings.name));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    streams.app.tap.add(null); // track user is active
    routeStack.removeLast();
    routeContext =
        routeStack.isEmpty ? null : routeStack.last.navigator?.context;
    streams.app.page.add(
        conformName(routeStack.isEmpty ? null : routeStack.last.settings.name));
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

    /// todo: put the whole path on it, rather than just the page name. this
    /// requires some attention because lots of stuff is keyed off the page.
    streams.app.page.add(
        conformName(routeStack.isEmpty ? null : routeStack.last.settings.name));
  }

  String conformName(String? name) =>
      name?.split('/').last.toTitleCase() ?? streams.app.page.value;
}
