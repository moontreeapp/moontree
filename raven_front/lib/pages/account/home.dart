import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  late bool importTrigger = false;
  late bool sendTrigger = false;
  late bool passwordTrigger = false;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0)).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.ease,
            reverseCurve: Curves.ease.flipped));
    listeners.add(streams.import.attempt.listen((value) {
      if ((value == null && importTrigger == true) ||
          (value != null && importTrigger == false)) {
        setState(() {
          importTrigger = !importTrigger;
        });
      }
    }));
    listeners.add(streams.spend.send.listen((value) {
      if ((value == null && sendTrigger == true) ||
          (value != null && sendTrigger == false)) {
        setState(() {
          sendTrigger = !sendTrigger;
        });
      }
    }));
    listeners.add(streams.password.update.listen((value) {
      if ((value == null && passwordTrigger == true) ||
          (value != null && passwordTrigger == false)) {
        setState(() {
          passwordTrigger = !passwordTrigger;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => importTrigger
      ? Loader(message: 'Importing')
      : sendTrigger
          ? Loader(message: 'Sending Transaction')
          : passwordTrigger
              ? Loader(message: 'Managing Wallet Encryption')
              : Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  body: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      // we want this to be liquid as well, #182
                      child: NotificationListener<UserScrollNotification>(
                          onNotification: visibilityOfSendReceive,
                          child: HoldingList())),
                  floatingActionButton:
                      SlideTransition(position: offset, child: NavBar()),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                );

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward &&
        controller.status == AnimationStatus.completed) {
      controller.reverse();
    } else if (notification.direction == ScrollDirection.reverse &&
        controller.status == AnimationStatus.dismissed) {
      controller.forward();
    }
    return true;
  }
}
