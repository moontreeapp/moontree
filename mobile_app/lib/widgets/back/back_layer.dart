import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';

class BackLayer extends StatefulWidget {
  BackLayer({Key? key}) : super(key: key);

  @override
  _BackLayerState createState() => _BackLayerState();
}

class _BackLayerState extends State<BackLayer> {
  late String pageTitle = 'Home';
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
    if (pageTitle.startsWith('Home')) {
      return NavMenu();
    }
    if (['Send', 'Transactions'].contains(pageTitle)) {
      return BalanceHeader(pageTitle: pageTitle);
    }
    if (['Asset'].contains(pageTitle)) {
      return BalanceHeader(pageTitle: pageTitle);
    }
    return Container(
      height: 0,
      width: 0,
    );
  }
}
