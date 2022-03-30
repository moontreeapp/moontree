import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/backdrop/lib/modified_draggable_scrollable_sheet.dart'
    as modified;
import 'package:raven_back/raven_back.dart';

class SwapHome extends StatefulWidget {
  @override
  _SwapHomeState createState() => _SwapHomeState();
}

class _SwapHomeState extends State<SwapHome>
    with SingleTickerProviderStateMixin {
  late AppContext currentContext = AppContext.wallet;
  late List listeners = [];
  static const double minExtent = .2;
  static const double maxExtent = 1.0;
  static const double initialExtent = maxExtent;
  late modified.DraggableScrollableController draggableScrollController;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.fling.listen((bool? value) {
      if (value != null) {
        fling(value == false ? value : null);
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
    draggableScrollController = modified.DraggableScrollableController();
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
                            child: Scroller(
                          controller: scrollController,
                          child: Text('swap\n\n\n\n\n\n\n\n\n\n\n\n'),
                        ));
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
