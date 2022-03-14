import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';

class BackLayer extends StatefulWidget {
  BackLayer({Key? key}) : super(key: key);

  @override
  _BackLayerState createState() => _BackLayerState();
}

class _BackLayerState extends State<BackLayer> {
  late String pageTitle = 'Wallet';
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
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pageTitle.startsWith('Wallet')) {
      return NavDrawer();
      //} else if (['Send', 'Transactions'].contains(pageTitle)) {
      //  Backdrop.of(components.navigator.routeContext!).revealBackLayer();
      //  return BalanceHeader(pageTitle: pageTitle);
    } else if (['Asset'].contains(pageTitle)) {
      Backdrop.of(components.navigator.routeContext!).revealBackLayer();
      return BalanceHeader(pageTitle: pageTitle);
      //} else if (['Receive'].contains(pageTitle)) {
      //  Backdrop.of(components.navigator.routeContext!).revealBackLayer();
      //  return Container(height: 100);
    }

    return Container(
      height: 0,
      width: 0,
    );
  }
}
