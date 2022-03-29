import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/backdrop/jm/curve.dart';
import 'package:raven_front/backdrop/jm/layers.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AppContext currentContext = AppContext.wallet;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.context.listen((AppContext value) {
      if (value != currentContext) {
        if (value == AppContext.wallet &&
            streams.app.manage.asset.value != null) {
          streams.app.manage.asset.add(null);
        } else if (value == AppContext.manage &&
            streams.app.wallet.asset.value != null) {
          streams.app.wallet.asset.add(null);
        }
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

  Widget body() => BackdropLayers(
        back: NavMenu(),
        front: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                Expanded(
                  child: DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.25,
                      maxChildSize: 1.0,
                      builder: ((context, scrollController) {
                        return FrontCurve(
                            child: HoldingList(
                                scrollController: scrollController));
                      })),
                ),
              ],
            ),
            NavBar(),
            Container(
              height: 118,
              color: Colors.transparent,
            )
          ],
        ),
      );
  //  front: Container(
  //    //height: 200, // variable height
  //    alignment: Alignment.bottomCenter,
  //    color: Colors.white,
  //    child: Container(
  //      height: 100,
  //      color: Colors.green,
  //    ),
  //  ),
  //);

  //Widget body() => Column(
  //      children: [
  //        Expanded(
  //            child: currentContext == AppContext.wallet
  //                ? HoldingList()
  //                : currentContext == AppContext.manage
  //                    ? AssetList()
  //                    : Text('swap')),
  //        NavBar(),
  //      ],
  //    );
}
