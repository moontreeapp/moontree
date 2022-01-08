//import 'package:backdrop/backdrop.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          icon: SvgPicture.asset('assets/icons/menu/menu.svg'))
      : pageTitle == 'Send'
          ? IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () =>
                  Navigator.pop(components.navigator.routeContext ?? context))
          : IconButton(
              icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
              onPressed: () =>
                  Navigator.pop(components.navigator.routeContext ?? context));
}
