import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class HomePage extends StatefulWidget {
  final AppContext appContext;

  const HomePage({Key? key, required this.appContext}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late List listeners = [];
  //static const double minExtent = .0736842105263158;
  static const double minExtent = .10;
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
    return BackdropLayers(
      back: NavMenu(),
      front: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          controller: draggableScrollController,
          snap: true,
          initialChildSize: initialExtent,
          minChildSize: minExtent,
          maxChildSize: maxExtent,
          builder: ((context, scrollController) {
            if (draggableScrollController.size == minExtent) {
              streams.app.setting.add('/settings');
            } else if (draggableScrollController.size == maxExtent) {
              streams.app.setting.add(null);
            }
            print("Min extent : ${draggableScrollController.size}");
            return FrontCurve(
                fuzzyTop: true,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    widget.appContext == AppContext.wallet
                        ? HoldingList(scrollController: scrollController)
                        : widget.appContext == AppContext.manage
                            ? AssetList(scrollController: scrollController)
                            : ListView(
                                controller: scrollController,
                                children: [
                                  Text('swap\n\n\n\n\n\n\n\n\n\n\n\n')
                                ],
                              ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (widget, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                                  begin: Offset(0, 1), end: Offset(0, 0))
                              .animate(animation),
                          child: widget,
                        );
                      },
                      child: draggableScrollController.size > (minExtent + 0.2)
                          ? NavBar(
                              actionButtons:
                                  widget.appContext == AppContext.wallet
                                      ? <Widget>[
                                          components.buttons.actionButton(
                                            context,
                                            label: 'send',
                                            link: '/transaction/send',
                                          ),
                                          components.buttons.actionButton(
                                            context,
                                            label: 'receive',
                                            link: '/transaction/receive',
                                          )
                                        ]
                                      : <Widget>[
                                          components.buttons.actionButton(
                                            context,
                                            label: 'create',
                                            onPressed: _produceCreateModal,
                                          )
                                        ])
                          : SizedBox(),
                    )
                  ],
                ));
          }),
        ),
      ),
    );
  }

  void _produceCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }

  Future<void> fling([bool? open]) async {
    if ((open ?? false)) {
      await flingDown();
    } else if (!(open ?? true)) {
      await flingUp();
    } else if (await draggableScrollController.size >=
        (maxExtent + minExtent) / 2) {
      await flingDown();
    } else {
      await flingUp();
    }
  }

  Future<void> flingDown() async => await draggableScrollController.animateTo(
        minExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized,
      );

  Future<void> flingUp() async {
    streams.app.setting.add(null);
    await draggableScrollController.animateTo(
      maxExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }
}
/* we want to hide the nav bar if we open the menu, so we can put this on a 
scaffold to do it, or we can do what is above: push it down w/ the front sheet.
NotificationListener<UserScrollNotification>(
                onNotification: visibilityOfSendReceive,
                child: currentContext == AppContext.wallet
                    ? HoldingList()
                    : currentContext == AppContext.manage
                        ? AssetList()
                        : Text('swap'))),
        floatingActionButton:
            SlideTransition(position: offset, child: NavBar()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward &&
        controller.status == AnimationStatus.completed) {
      controller.reverse();
    } else if (notification.direction == ScrollDirection.reverse &&
        controller.status == AnimationStatus.dismissed) {
      ScaffoldMessenger.of(context).clearSnackBars();
      controller.forward();
    }
    return true;
  }
*/


/*
we should be able to use this to apply a scrim to the front layer
  Widget _buildInactiveLayer(BuildContext context) {
    return Offstage(
      offstage: animationController.status == AnimationStatus.completed,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(animationController),
        child: GestureDetector(
          onTap: () => fling(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: widget.frontLayerScrim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  */
