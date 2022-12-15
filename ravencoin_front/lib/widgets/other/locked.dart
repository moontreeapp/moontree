import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class LockedOutTime extends StatefulWidget {
  const LockedOutTime({Key? key}) : super(key: key);

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
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    slowAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(slowController);
  }

  @override
  void dispose() {
    slowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    slowController.forward(from: 0.0);
    slowController.duration = Duration(
        milliseconds: /*min(1000 * 60 * 2,*/ services
                .password.lockout.timeFromAttempts *
            2 /*)*/);

    /// fade removal requested:tel
    return //FadeTransition(
        // opacity: slowAnimation,
        // child:
        // visibility not necessary since the text just is blank in empty case
        //Visibility(
        //    visible: services.password.lockout.timeFromAttempts ~/ 1000 >= 0,
        //    child:
        const LockedOutTimeContent()
        //)
        //)
        ;
  }
}

class LockedOutTimeContent extends StatefulWidget {
  const LockedOutTimeContent({Key? key}) : super(key: key);

  @override
  _LockedOutTimeContentState createState() => _LockedOutTimeContentState();
}

class _LockedOutTimeContentState extends State<LockedOutTimeContent> {
  late Timer _timer;
  int originalMilliseconds = 0;

  void startTimer() {
    const Duration oneSec = const Duration(seconds: 1);
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
    final DateTime loginTime = services.password.lockout.lastFailedAttempt.add(
        Duration(milliseconds: services.password.lockout.timeFromAttempts));
    final int milliseconds =
        max(0, loginTime.difference(DateTime.now()).inMilliseconds);
    originalMilliseconds = milliseconds > originalMilliseconds
        ? milliseconds
        : milliseconds <= 0
            ? 0
            : originalMilliseconds;
    final int seconds = milliseconds ~/ 1000;
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    const String tryAgain = 'Please try Again in ';
    return Text(
        min > 0 && sec > 0
            ? '$tryAgain$min minute${min == 1 ? '' : 's'} and $sec second${sec == 1 ? '' : 's'}'
            : sec > 0 || (milliseconds > 0 && originalMilliseconds >= 1000)
                ? '$tryAgain${sec + 1} second${sec + 1 == 1 ? '.' : 's.'}'
                : '',
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: AppColors.error));
  }
}
