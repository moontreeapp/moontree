import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';

class PageLead extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  PageLead({Key? key, required this.scaffoldKey}) : super(key: key);

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
          onPressed: () => widget.scaffoldKey.currentState!.openDrawer(),
          padding: EdgeInsets.only(left: 16),
          icon: Image(image: AssetImage('assets/icons/menu_24px.png')))
      : components.buttons.back(context);
}
