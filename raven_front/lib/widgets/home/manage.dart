import 'package:flutter/material.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';

class ManageHome extends StatefulWidget {
  @override
  _ManageHomeState createState() => _ManageHomeState();
}

class _ManageHomeState extends State<ManageHome>
    with SingleTickerProviderStateMixin {
  late List listeners = [];
  static const double minExtent = .2;
  static const double maxExtent = 1.0;
  static const double initialExtent = maxExtent;
  late DraggableScrollableController draggableScrollController;

  @override
  void initState() {
    super.initState();
    draggableScrollController = DraggableScrollableController();
    listeners.add(streams.app.fling.listen((bool? value) async {
      if (value != null) {
        await fling(value == false ? value : null);
        streams.app.fling.add(null);
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    //draggableScrollController.dispose();
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
                  child: DraggableScrollableActuator(
                    child: DraggableScrollableSheet(
                      controller: draggableScrollController,
                      snap: false,
                      initialChildSize: initialExtent,
                      minChildSize: minExtent,
                      maxChildSize: maxExtent,
                      builder: ((context, scrollController) {
                        return FrontCurve(
                            child:
                                AssetList(scrollController: scrollController));
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

  Future<void> fling([bool? open]) async {
    var flingDown = () async => await draggableScrollController.animateTo(
          minExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
        );
    var flingUp = () async => await draggableScrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
        );
    if ((open ?? false)) {
      flingDown();
    } else if (!(open ?? true)) {
      flingUp();
    } else if (await draggableScrollController.size >=
        (maxExtent + minExtent) / 2) {
      flingDown();
    } else {
      flingUp();
    }
  }
}
