import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_front/widgets/widgets.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;

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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: NotificationListener<UserScrollNotification>(
                onNotification: visibilityOfSendReceive, child: HoldingList())),
        floatingActionButton:
            SlideTransition(position: offset, child: NavBar()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
