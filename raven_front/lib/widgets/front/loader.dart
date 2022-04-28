import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';

class Loader extends StatefulWidget {
  final String message;
  final bool staticImage = false; // enforce false, evaluate after release build
  final bool returnHome;
  const Loader({
    this.message = 'Loading...',
    this.returnHome = true,
    staticImage = false,
  }) : super();

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  //DateTime startTime = DateTime.now();
  late List<StreamSubscription> listeners = [];
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    streams.app.loading.add(true);
    // not ideal sends to home page even on error - in order to go back
    // intelligently we must know which stream matters and listen to that
    // like streams.spend.success or whatever.
    streams.app.snack.add(null); // clear out first just in case.
    listeners.add(streams.app.snack.listen((Snack? value) async {
      if (value != null) {
        if (!widget.staticImage) {
          var duration = 1330;
          var waited = DateTime.now().difference(startTime).inMilliseconds;
          var wait = (duration - (waited % duration)) % duration;
          await Future.delayed(Duration(milliseconds: wait));
        }
        if (widget.returnHome) {
          Navigator.popUntil(
              components.navigator.routeContext!, ModalRoute.withName('/home'));
        } else {
          Navigator.of(context).pop();
        }
      }
    }));
    if (!widget.staticImage) {
      startTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    streams.app.loading.add(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrontCurve(
        fuzzyTop: false,
        frontLayerBoxShadow: [],
        color: AppColors.white87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.message,
                style: Theme.of(context).textTheme.headline2,
              ),
              SizedBox(height: 16),
              widget.staticImage
                  ? Image.asset(
                      'assets/logo/moontree_logo.png',
                      height: 56,
                      width: 56,
                    )
                  : Lottie.asset(
                      'assets/spinner/moontree_spinner_v2_002_1_recolored.json',
                      animate: true,
                      repeat: true,
                      width: 100,
                      height: 58.6,
                      fit: BoxFit.fitWidth,
                    ),
            ]));
  }
}
