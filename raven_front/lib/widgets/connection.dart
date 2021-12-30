import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';

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

  @override
  void initState() {
    super.initState();
    _animationControllerActive = _animationControllerActive ??
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationControllerUp = _animationControllerUp ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationControllerDown = _animationControllerDown ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    listeners.add(services.busy.client.stream.listen((value) {
      if (value == null) {
        setState(() {
          lastestClientValue = value;
          connected = false;
        });
      } else {
        setState(() {
          lastestClientValue = value;
          connected = true;
        });
      }
    }));
    listeners.add(services.busy.process.stream.listen((value) async {
      if (value == null) {
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          setState(() {
            lastestProcessValue = value;
            working = false;
            activity = activity == 'working' ? 'down' : 'idle';
          });
        }
      } else {
        setState(() {
          lastestProcessValue = value;
          working = true;
          activity = activity == 'idle' ? 'up' : 'working';
        });
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (var listener in listeners) {
      print('7');
      listener.cancel();
      print('8');
    }
    // _ConnectionLightState.dispose failed to call super.dispose.
    print('0');
    // ignore: invalid_use_of_protected_member
    _animationControllerActive?.clearStatusListeners();
    print('1');
    // ignore: invalid_use_of_protected_member
    _animationControllerUp?.clearStatusListeners();
    print('2');
    // ignore: invalid_use_of_protected_member
    _animationControllerDown?.clearStatusListeners();
    print('3');
    _animationControllerActive?.dispose();
    print('4');
    _animationControllerUp?.dispose();
    print('5');
    _animationControllerDown?.dispose();
    print('6');
    print('9');
    print('10');
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
      connectionMessage = lastestClientValue;
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
        /// for manual testing
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
        IconButton(
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Text(status),
                  content: Text('Connection Status: $connectionMessage \n\n'
                      'Background Tasks: $processMessage'))),
          icon: Stack(
            children: [
              Visibility(
                  visible: activity == 'idle',
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          connected ? Color(0xFF4CAF50) : Color(0xFFF44336),
                          BlendMode.srcATop),
                      child: Image(
                          image: AssetImage("assets/status/center.png")))),
              Visibility(
                  visible: activity == 'working',
                  child: RotationTransition(
                      child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              connected ? Color(0xFF4CAF50) : Color(0xFFF44336),
                              BlendMode.srcATop),
                          child: Image(
                              image: AssetImage("assets/status/left.png"))),
                      alignment: Alignment.center,
                      turns: _animationControllerActive!)),
              Visibility(
                  visible: activity == 'up',
                  child: RotationTransition(
                      child: RotationTransition(
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  connected
                                      ? Color(0xFF4CAF50)
                                      : Color(0xFFF44336),
                                  BlendMode.srcATop),
                              child: Image(
                                  image:
                                      AssetImage("assets/status/center.png"))),
                          alignment: Alignment(.3, 0),
                          turns: _animationControllerUp!),
                      alignment: Alignment.center,
                      turns: _animationControllerUp!)),
              Visibility(
                visible: activity == 'down',
                child: Transform.rotate(
                  angle: 6.283184 * _animationControllerActive!.value,
                  child: RotationTransition(
                      child: RotationTransition(
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  connected
                                      ? Color(0xFF4CAF50)
                                      : Color(0xFFF44336),
                                  BlendMode.srcATop),
                              child: Image(
                                  image:
                                      AssetImage("assets/status/center.png"))),
                          alignment: Alignment(.3, 0),
                          turns: _animationControllerDown!),
                      alignment: Alignment.center,
                      turns: _animationControllerDown!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
