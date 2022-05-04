import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raven_front/theme/colors.dart';

class LockedOutTime extends StatefulWidget {
  final int timeout; // milliseconds
  final DateTime lastFailedAttempt;
  final bool showCountdown;

  LockedOutTime({
    required this.lastFailedAttempt,
    this.timeout = 1,
    this.showCountdown = false,
    Key? key,
  }) : super(key: key);

  @override
  _LockedOutTimeState createState() => _LockedOutTimeState();
}

class _LockedOutTimeState extends State<LockedOutTime>
    with SingleTickerProviderStateMixin {
  late AnimationController slowController;
  late Animation<double> slowAnimation;

  @override
  void initState() {
    super.initState();
    slowController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    slowAnimation = Tween(begin: 1.0, end: 0.0).animate(slowController);
  }

  @override
  void dispose() {
    slowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    slowController.forward(from: 0.0);
    slowController.duration =
        Duration(milliseconds: /*min(1000 * 60 * 2,*/ widget.timeout * 2 /*)*/);
    //print(widget.timeout);
    print(widget.timeout ~/ 1000);
    return FadeTransition(
        opacity: slowAnimation,
        child: Visibility(
            //visible: widget.showCountdown || widget.timeout ~/ 1000 >= 1,
            visible: widget.timeout ~/ 1000 >= 1,
            //visible: true,
            child: LockedOutTimeContent(
              timeout: widget.timeout,
              lastFailedAttempt: widget.lastFailedAttempt,
            )));
  }
}

class LockedOutTimeContent extends StatefulWidget {
  final int timeout; // milliseconds
  final DateTime lastFailedAttempt;

  LockedOutTimeContent({
    required this.lastFailedAttempt,
    this.timeout = 1,
    Key? key,
  }) : super(key: key);

  @override
  _LockedOutTimeContentState createState() => _LockedOutTimeContentState();
}

class _LockedOutTimeContentState extends State<LockedOutTimeContent> {
  late Timer _timer;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginTime =
        widget.lastFailedAttempt.add(Duration(milliseconds: widget.timeout));
    final seconds = max(0, loginTime.difference(DateTime.now()).inSeconds);
    final min = seconds ~/ 60;
    var sec = (seconds % 60);
    sec = [60, 0].contains(sec) ? sec : sec + 1; // show binary numbers
    return Text(
        min > 0 && sec > 0
            ? 'Locked out for ' +
                min.toString() +
                ' minute${min == 1 ? '' : 's'} and ' +
                sec.toString() +
                ' second${sec == 1 ? '' : 's'}'
            : sec > 0
                ? 'Locked out for ' +
                    sec.toString() +
                    ' second${sec == 1 ? '' : 's'}'
                : '', //make it it's own widget to countdown
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: AppColors.error));
  }
}
