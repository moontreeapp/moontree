import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';

class HomePage extends StatefulWidget {
  final AppContext appContext;

  const HomePage({Key? key, required this.appContext}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late List listeners = [];
  static const double minExtent = .0736842105263158;
  static const double maxExtent = 1.0;
  static const double initialExtent = maxExtent;
  late DraggableScrollableController draggableScrollController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //minExtent = 1-(MediaQuery.of(context).size.height - 56)  // pix
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
                        if (draggableScrollController.size == minExtent) {
                          streams.app.setting.add('/settings');
                        } else if (draggableScrollController.size ==
                            maxExtent) {
                          streams.app.setting.add(null);
                        }
                        return FrontCurve(
                            child: widget.appContext == AppContext.wallet
                                ? HoldingList(
                                    scrollController: scrollController)
                                : widget.appContext == AppContext.manage
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

  Future<void> fling([bool? open]) async {
    var flingDown = () async => await draggableScrollController.animateTo(
          minExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
        );
    var flingUp = () async {
      streams.app.setting.add(null);
      await draggableScrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized,
      );
    };
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
