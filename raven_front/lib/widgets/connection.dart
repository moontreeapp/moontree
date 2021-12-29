import 'package:flutter/material.dart';

class ConnectionLight extends StatefulWidget {
  final String name;

  ConnectionLight({Key? key, required this.name}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin, AnimationEagerListenerMixin {
  AnimationController? _animationControllerActive;
  AnimationController? _animationControllerUp;
  AnimationController? _animationControllerDown;
  String activity = 'up';

  @override
  void initState() {
    super.initState();
    _animationControllerActive = _animationControllerActive ??
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationControllerUp = _animationControllerUp ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationControllerDown = _animationControllerDown ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    // ignore: invalid_use_of_protected_member
    _animationControllerActive?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerUp?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerDown?.clearStatusListeners();
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
          setState(() => activity = 'up');
        }
      });
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Visibility(
                visible: activity == 'active',
                child: RotationTransition(
                    child: Image(
                        image: AssetImage("assets/spinner/leftdottrans.png")),
                    alignment: Alignment.center,
                    turns: _animationControllerActive!)),
            Visibility(
              visible: activity == 'up',
              child: RotationTransition(
                  child: RotationTransition(
                      child: Image(
                          image:
                              AssetImage("assets/spinner/centerdottrans.png")),
                      alignment: Alignment(.3, 0),
                      turns: _animationControllerUp!),
                  alignment: Alignment.center,
                  turns: _animationControllerUp!),
            ),
            Visibility(
              visible: activity == 'down',
              child: Transform.rotate(
                angle: 6.283184 * _animationControllerActive!.value,
                child: RotationTransition(
                    child: RotationTransition(
                        child: Image(
                            image: AssetImage(
                                "assets/spinner/centerdottrans.png")),
                        alignment: Alignment(.3, 0),
                        turns: _animationControllerDown!),
                    alignment: Alignment.center,
                    turns: _animationControllerDown!),
              ),
            ),
          ],
        ),
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerUp!.value);
        //      TickerFuture tickerFuture =
        //          _animationControllerUp!.forward(from: 0.0);
        //      tickerFuture.timeout(Duration(seconds: 1), onTimeout: () {
        //        _animationControllerUp!.forward(from: 0);
        //        _animationControllerUp!.stop(canceled: true);
        //        _animationControllerActive?.value = 0.0;
        //        _animationControllerActive?.repeat();
        //        setState(() => activity = 'active');
        //      });
        //    },
        //    child: Text('start')),
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerActive!.value);
        //      setState(() => activity = 'down');
        //    },
        //    child: Text('stop')),
        //Text('Loading...${widget.name}... $activity'),
      ],
    );
  }
}

/// unused
class TimeStopper extends StatelessWidget {
  final AnimationController controller;

  const TimeStopper({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print(controller.value);
          if (controller.isAnimating) {
            controller.stop();
          } else {
            controller.repeat();
          }
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.black),
          width: 100,
          height: 100,
        ));
  }
}
