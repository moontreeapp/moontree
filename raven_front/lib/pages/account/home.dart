import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/utils/zips.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  late AppContext currentContext = AppContext.wallet;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    if (streams.app.asset.value != null) streams.app.asset.add(null);
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0)).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.ease,
            reverseCurve: Curves.ease.flipped));
    listeners.add(streams.app.context.listen((AppContext value) {
      if (value != currentContext) {
        setState(() {
          currentContext = value;
        });
      }
    }));
    listeners.add(streams.app.hideNav.listen((bool? value) {
      if (value != null) {
        if (value) {
          controller.forward();
        } else {
          controller.reverse();
        }
      }
    }));
    listeners.add(res.settings.changes.listen((Change change) {
      setState(() {});
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
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            // we want this to be liquid as well, #182
            child: NotificationListener<UserScrollNotification>(
                onNotification: visibilityOfSendReceive,
                child: currentContext == AppContext.wallet
                    ? HoldingList()
                    : currentContext == AppContext.manage
                        ? AssetList()
                        : Text('swap'))),
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
      ScaffoldMessenger.of(context).clearSnackBars();
      controller.forward();
    }
    return true;
  }
}
