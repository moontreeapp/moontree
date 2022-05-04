import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raven_front/theme/colors.dart';

class LockedOutTime extends StatefulWidget {
  final int timeout;
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

    /// fade removal requested:tel
    return //FadeTransition(
        // opacity: slowAnimation,
        // child:
        // visibility not necessary since the text just is blank in empty case
        //Visibility(
        //    visible: widget.timeout ~/ 1000 >= 0,
        //    child:
        LockedOutTimeContent(
      timeout: widget.timeout,
      lastFailedAttempt: widget.lastFailedAttempt,
    )
        //)
        //)
        ;
  }
}

class LockedOutTimeContent extends StatefulWidget {
  final int timeout;
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
  int originalMilliseconds = 0;

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
    final milliseconds =
        max(0, loginTime.difference(DateTime.now()).inMilliseconds);
    originalMilliseconds = milliseconds > originalMilliseconds
        ? milliseconds
        : milliseconds <= 0
            ? 0
            : originalMilliseconds;
    final seconds = milliseconds ~/ 1000;
    final min = seconds ~/ 60;
    final sec = (seconds % 60);
    final tryAgain = 'Please try Again in ';
    return Text(
        min > 0 && sec > 0
            ? tryAgain +
                min.toString() +
                ' minute${min == 1 ? '' : 's'} and ' +
                sec.toString() +
                ' second${sec == 1 ? '' : 's'}'
            : sec > 0 || (milliseconds > 0 && originalMilliseconds >= 1000)
                ? tryAgain +
                    (sec + 1).toString() +
                    ' second${sec + 1 == 1 ? '' : 's'}'
                : '',
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: AppColors.error));
  }
}
