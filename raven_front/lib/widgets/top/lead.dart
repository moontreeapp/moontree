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
  late String pageTitle = 'Wallet';
  late String? settingTitle = null;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.listen((value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
    listeners.add(streams.app.setting.listen((value) {
      if (value != settingTitle) {
        setState(() {
          settingTitle = value;
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
  Widget build(BuildContext context) =>
      {
        '/settings/import_export': IconButton(
            splashRadius: 24,
            icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
            onPressed: () => streams.app.setting.add('/settings')),
        '/settings/settings': IconButton(
            splashRadius: 24,
            icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
            onPressed: () => streams.app.setting.add('/settings'))
      }[settingTitle] ??
      {
        'Wallet': IconButton(
            splashRadius: 24,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              var open =
                  Backdrop.of(context).isBackLayerRevealed ? false : true;
              streams.app.hideNav.add(open);
              streams.app.setting.add(open ? 'open' : null);
              Backdrop.of(context).fling();
            },
            padding: EdgeInsets.only(left: 16),
            icon: SvgPicture.asset('assets/icons/menu/menu.svg')),
        '': Container(),
      }[pageTitle] ??
      (['Send', 'Scan'].contains(pageTitle)
          ? IconButton(
              splashRadius: 24,
              icon: Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () =>
                  Navigator.pop(components.navigator.routeContext ?? context))
          : IconButton(
              splashRadius: 24,
              icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
              onPressed: () =>
                  Navigator.pop(components.navigator.routeContext ?? context)));
}
