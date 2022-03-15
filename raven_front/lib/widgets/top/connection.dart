import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class ConnectionLight extends StatefulWidget {
  ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin, AnimationEagerListenerMixin {
  AnimationController? _animationControllerActive;
  AnimationController? _animationControllerUp;
  AnimationController? _animationControllerDown;
  String activity = 'idle';
  List<StreamSubscription> listeners = [];
  String? lastestClientValue;
  String? lastestProcessValue;
  bool connected = false;
  bool working = false;
  Color connectedColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _animationControllerActive = _animationControllerActive ??
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationControllerUp = _animationControllerUp ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationControllerDown = _animationControllerDown ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    /// to make this animate correctly and have correct colors I think we need
    /// to combine lastest or something on these listeners.
    /// basically there are 3 states:
    /// 1. disconnected, busy trying to connect
    /// 2. connected, busy working (interacting with server or running process)
    /// 3. connected, idle
    /// and 6 transitions:
    /// 1. connected idle -> disconnected busy : green still -> red moving, turn red, start moving, loop.
    /// 2. connected busy -> disconnected busy : green moving -> red moving, turn red, keep looping
    /// 3. connected idle -> connected busy : green still -> green moving, start moving, loop
    /// 4. connected busy -> connected idle : green moving -> green still, stop moving
    /// 5. disconnected busy -> connected idle : red moving -> green still, turn green, stop moving
    /// 6. disconnected busy -> connected busy : red moving -> green moving, turn green, loop
    /// or rather
    ///   2 movement transitions:
    ///     1. idle -> busy : still -> moving : start moving, loop animation
    ///     2. busy -> idle : moving -> still : stop moving, show image
    ///   and 2 color transitions:
    ///     1. connected -> disconnected : green -> red : turn red
    ///     2. disconnected -> connected : red -> green : turn green
    /// So color should just be a variable set by listener
    /// and movement needs to remember previous state when changed.
    /// So they probably don't need to be combined actually. we should be able
    /// to keep them separated.
    listeners
        .add(streams.client.connected.listen((bool value) => value != connected
            ? setState(() {
                connected = value;
                connectedColor = value ? Color(0xFF4CAF50) : Color(0xFFF44336);
              })
            : () {/*do nothing*/}));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    // _ConnectionLightState.dispose failed to call super.dispose.
    // ignore: invalid_use_of_protected_member
    _animationControllerActive?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerActive?.clearListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerUp?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerUp?.clearListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerDown?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerDown?.clearListeners();
    _animationControllerActive?.dispose();
    _animationControllerUp?.dispose();
    _animationControllerDown?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (activity == 'down') {
      _animationControllerDown!.forward(from: 0.50);
      _animationControllerDown!.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() => activity = 'idle');
        }
      });
    } else if (activity == 'up') {
      TickerFuture tickerFuture = _animationControllerUp!.forward(from: 0.0);
      tickerFuture.timeout(Duration(milliseconds: 1000), onTimeout: () {
        //_animationControllerUp!.forward(from: 0);
        //_animationControllerUp!.stop(canceled: true);
        _animationControllerActive?.value = 0.0;
        _animationControllerActive?.repeat();
        setState(() => activity = 'working');
      }); //rgba(244, 67, 54, 1)
    }
    var status;
    var connectionMessage;
    var processMessage;
    if (connected) {
      status = 'Connected';
      connectionMessage = lastestClientValue ?? 'Connection established.';
    } else {
      status = 'Disconnected';
      connectionMessage =
          'Unable to communicate with the Ravencoin Electrum Server. Please check your internet connection.';
    }
    if (working) {
      processMessage = lastestProcessValue;
    } else {
      processMessage = 'Currently idle.';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// for raw manual testing
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerUp!.value);
        //      setState(() => activity = 'up');
        //    },
        //    child: Text('$activity')),
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerActive!.value);
        //      setState(() => activity = 'down');
        //    },
        //    child: Text('stop')),
        /// for manual testing by stream use
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerUp!.value);
        //      setState(() => services.busy.processOn('test'));
        //    },
        //    child: Text('$activity')),
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerActive!.value);
        //      setState(() => services.busy.processOff('test'));
        //    },
        //    child: Text('stop')),
        IconButton(
          splashRadius: 24,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            showDialog(
                //context: context,
                context: components.navigator.routeContext!,
                builder: (BuildContext context) => AlertDialog(
                    title: Text(status),
                    content: Text('Connection Status: $connectionMessage \n\n'
                        'Current Task: $processMessage')));
          },
          icon: [
            //if (activity == 'idle')
            ColorFiltered(
                colorFilter:
                    ColorFilter.mode(connectedColor, BlendMode.srcATop),
                child: Image(image: AssetImage("assets/status/center.png"))),
            //if (activity == 'working')
            //  RotationTransition(
            //      child: ColorFiltered(
            //          colorFilter:
            //              ColorFilter.mode(connectedColor, BlendMode.srcATop),
            //          child:
            //              Image(image: AssetImage("assets/status/left.png"))),
            //      alignment: Alignment.center,
            //      turns: _animationControllerActive!),
            //if (activity == 'up')
            //  RotationTransition(
            //      child: RotationTransition(
            //          child: ColorFiltered(
            //              colorFilter: ColorFilter.mode(
            //                connectedColor,
            //                BlendMode.srcATop,
            //              ),
            //              child: Image(
            //                  image: AssetImage("assets/status/center.png"))),
            //          alignment: Alignment(.3, 0),
            //          turns: _animationControllerUp!),
            //      alignment: Alignment.center,
            //      turns: _animationControllerUp!),
            //if (activity == 'down')
            //  Transform.rotate(
            //    angle: 6.283184 * _animationControllerActive!.value,
            //    child: RotationTransition(
            //        child: RotationTransition(
            //            child: ColorFiltered(
            //                colorFilter: ColorFilter.mode(
            //                  connectedColor,
            //                  BlendMode.srcATop,
            //                ),
            //                child: Image(
            //                    image: AssetImage("assets/status/center.png"))),
            //            alignment: Alignment(.3, 0),
            //            turns: _animationControllerDown!),
            //        alignment: Alignment.center,
            //        turns: _animationControllerDown!),
            //  ),
          ][0],
        ),
      ],
    );
  }
}
