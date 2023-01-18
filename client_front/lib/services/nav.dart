import 'package:flutter/material.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/pages/pages.dart';

class NavWrap {
  void navigate<T>(
      //BuildContext context,
      //Future Function(String routeName, {Object? arguments}) navigation,
      //required String routeName,
      //Map<String, dynamic>? arguments,
      {
    required Future<T> Function() navCall,
    Function? before,
    Function? after,
  }) {
    if (before != null) {
      before();
    }
    //ScaffoldMessenger.of(context).clearSnackBars();
    //Navigator.of(components.routes.routeContext!).pushNamed(
    navCall();
    if (after != null) {
      after();
    }
  }

  void goTo(String link) {
    if (link == '/settings/about') {
      navigate(
        navCall: () => Navigator.of(components.routes.routeContext!).push(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                pages.routes(components.routes.routeContext!)[link]!(
                    components.routes.routeContext!), //Page1(),
            transitionDuration: Duration(seconds: 1),
            reverseTransitionDuration: Duration(seconds: 1),
          ),
        ),
        before: () => print('before'),
        after: () => print('after'),
      );
    }
  }
}

/*
*/
