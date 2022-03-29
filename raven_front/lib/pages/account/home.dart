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
  late BuildContext? draggableSheetContext;
  static const double minExtent = .26;
  static const double maxExtent = 1.0;
  //late ScrollController draggableScrollController;
  late modified.DraggableScrollableController draggableScrollController =
      modified.DraggableScrollableController();
  bool isExpanded = true;
  double initialExtent = maxExtent;

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1,
    );
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
                  child: modified.DraggableScrollableActuator(
                    child: modified.DraggableScrollableSheet(
                      controller: draggableScrollController,
                      initialChildSize: initialExtent,
                      minChildSize: minExtent,
                      maxChildSize: maxExtent,
                      builder: ((context, scrollController) {
                        draggableSheetContext = context;
                        return FrontCurve(
                            child: HoldingList(
                                scrollController: scrollController));
                      }),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: fling,
              child: NavBar(),
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

  void fling() {
    print('fling');

    /// scrolls the list only
    //draggableScrollController.animateTo(
    //  0, // to the top
    //  duration: animationController.duration!,
    //  curve: Curves.ease,
    //);
    //if (draggableSheetContext != null) {
    //  //setState(() {
    //  //  initialExtent = isExpanded ? minExtent : maxExtent;
    //  //  isExpanded = !isExpanded;
    //  //});
    //  DraggableScrollableActuator.reset(draggableSheetContext!);
    //}
    if (draggableScrollController.size < maxExtent) {
      draggableScrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized,
      );
    } else {
      draggableScrollController.animateTo(
        minExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }
}
