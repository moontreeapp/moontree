import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/backdrop/lib/modified_draggable_scrollable_sheet.dart'
    as modified;
import 'package:raven_back/raven_back.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AppContext currentContext = AppContext.wallet;
  late List listeners = [];
  static const double minExtent = .2;
  static const double maxExtent = 1.0;
  late modified.DraggableScrollableController draggableScrollController =
      modified.DraggableScrollableController();
  double initialExtent = maxExtent;

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

    listeners.add(streams.app.fling.listen((bool? value) {
      if (value != null) {
        fling(true);
        streams.app.fling.add(null);
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
                  child: modified.DraggableScrollableActuator(
                    child: modified.DraggableScrollableSheet(
                      controller: draggableScrollController,
                      snap: false,
                      initialChildSize: initialExtent,
                      minChildSize: minExtent,
                      maxChildSize: maxExtent,
                      builder: ((context, scrollController) {
                        return FrontCurve(
                            child: currentContext == AppContext.wallet
                                ? HoldingList(
                                    scrollController: scrollController)
                                : currentContext == AppContext.manage
                                    ? AssetList(
                                        scrollController: scrollController)
                                    : Scroller(
                                        controller: scrollController,
                                        child: Text(
                                            'swap\n\n\n\n\n\n\n\n\n\n\n\n')));
                      }),
                    ),
                  ),
                ),
              ],
            ),
            NavBar(),
          ],
        ),
      );

  void fling([bool? open]) {
    var flingDown = () => draggableScrollController.animateTo(
          minExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
        );
    var flingUp = () => draggableScrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
        );
    if ((open ?? false)) {
      flingDown();
    } else if (!(open ?? true)) {
      flingUp();
    } else if (draggableScrollController.size >= (maxExtent + minExtent) / 2) {
      flingDown();
    } else {
      flingUp();
    }
  }
}
