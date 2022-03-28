import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AppContext currentContext = AppContext.wallet;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    if (streams.app.manage.asset.value != null)
      streams.app.manage.asset.add(null);
    listeners.add(streams.app.context.listen((AppContext value) {
      if (value != currentContext) {
        setState(() {
          currentContext = value;
        });
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
            child: Column(
              children: [
                Expanded(
                    child: currentContext == AppContext.wallet
                        ? HoldingList()
                        : currentContext == AppContext.manage
                            ? AssetList()
                            : Text('swap')),
                NavBar(),
              ],
            )),
      );
}
