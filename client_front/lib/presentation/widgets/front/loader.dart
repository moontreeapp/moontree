import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class Loader extends StatefulWidget {
  final String message;
  final int? playCount; // how long to show before dismissing loading screen
  final Function? then; // function to call when dismissed
  final bool returnHome;
  final bool staticImage = false; // enforce false, evaluate after release build
  const Loader({
    this.message = 'Loading...',
    this.playCount,
    this.then,
    this.returnHome = true,
    //this.staticImage = false, //unused
  }) : super();

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  //DateTime startTime = DateTime.now();
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  late DateTime startTime;

  Future<void> _init(int duration) async {
    await Future<void>.delayed(
        Duration(milliseconds: duration * widget.playCount!));
    _goSomewhere();
    await Future<void>.delayed(const Duration(milliseconds: 170));
    _doSomething();
  }

  void _goSomewhere() {
    if (widget.returnHome) {
      streams.app.setting.add(null);
      streams.app.fling.add(false);
      //await Future<void>.delayed(const Duration(milliseconds: 100)); // doesn't help
      Navigator.popUntil(
        components.routes.routeContext!,
        ModalRoute.withName('/home'),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _doSomething() {
    if (widget.then != null) {
      widget.then!();
    }
  }

  @override
  void initState() {
    super.initState();
    streams.app.loading.add(true);
    // not ideal sends to home page even on error - in order to go back
    // intelligently we must know which stream matters and listen to that
    // like streams.spend.success or whatever.
    streams.app.snack.add(null); // clear out first just in case.
    const int duration = 1330;
    if (widget.playCount == null) {
      listeners.add(streams.app.snack.listen((Snack? value) async {
        if (value != null) {
          if (!widget.staticImage) {
            final int waited =
                DateTime.now().difference(startTime).inMilliseconds;
            final int wait = (duration - (waited % duration)) % duration;
            await Future<void>.delayed(Duration(milliseconds: wait));
          }
          _goSomewhere();
          _doSomething();
        }
      }));
    } else {
      _init(duration);
    }
    if (!widget.staticImage) {
      startTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    streams.app.loading.add(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrontCurve(
        fuzzyTop: false,
        frontLayerBoxShadow: const <BoxShadow>[],
        color: AppColors.white87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.message,
                style: Theme.of(context).textTheme.headline2,
              ),
              const SizedBox(height: 16),
              if (widget.staticImage)
                Image.asset(
                  'assets/logo/moontree_logo.png',
                  height: 56,
                  width: 56,
                )
              else
                Lottie.asset(
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
