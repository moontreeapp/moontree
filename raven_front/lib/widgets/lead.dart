//import 'package:backdrop/backdrop.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';

class PageLead extends StatefulWidget {
  final BuildContext mainContext;

  PageLead({Key? key, required this.mainContext}) : super(key: key);

  @override
  _PageLead createState() => _PageLead();
}

class _PageLead extends State<PageLead> {
  String pageTitle = 'Wallet';
  List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.stream.listen((value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => pageTitle == 'Wallet'
      ? IconButton(
          onPressed: () => Backdrop.of(context).fling(),
          padding: EdgeInsets.only(left: 16),
          icon: Image(image: AssetImage('assets/icons/menu/menu.png')))
      : components.buttons.back(components.navigator.routeContext ?? context);
}
