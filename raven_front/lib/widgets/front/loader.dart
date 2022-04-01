import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class Loader extends StatefulWidget {
  final String message;
  final bool returnHome;
  const Loader({this.message = 'Loading...', this.returnHome = true}) : super();

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  late List<StreamSubscription> listeners = [];

  @override
  void initState() {
    super.initState();
    // not ideal sends to home page even on error - in order to go back
    // intelligently we must know which stream matters and listen to that
    // like streams.spend.success or whatever.
    streams.app.snack.add(null); // clear out first just in case.
    listeners.add(streams.app.snack.listen((Snack? value) {
      if (value != null) {
        if (widget.returnHome) {
          Navigator.popUntil(
              components.navigator.routeContext!, ModalRoute.withName('/home'));
        } else {
          Navigator.of(context).pop();
        }
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrontCurve(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Text(
            widget.message,
            style: Theme.of(context).textTheme.headline2,
          ),
          SizedBox(height: 4),
          Image.asset(
            'assets/logo/moontree_logo.png',
            height: 56,
            width: 56,
          ),
        ]));
  }
}
