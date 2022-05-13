import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/theme/theme.dart';

class CoinSpecTabs extends StatefulWidget {
  CoinSpecTabs({Key? key}) : super(key: key);

  @override
  _CoinSpecTabsState createState() => _CoinSpecTabsState();

  static Map<int, String> get tabIndex => {0: 'HISTORY', 1: 'DATA'};
}

class _CoinSpecTabsState extends State<CoinSpecTabs>
    with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(changeContent);
  }

  @override
  void dispose() {
    tabController.removeListener(changeContent);
    tabController.dispose();
    super.dispose();
  }

  void changeContent() =>
      streams.app.coinspec.add(CoinSpecTabs.tabIndex[tabController.index]);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        // <-- clips to the 200x200 [Container] below
        child: Container(
            height: 56,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child:
                //BackdropFilter(
                //    filter: ImageFilter.blur(
                //        sigmaX: 2.0, sigmaY: 2.0, tileMode: TileMode.clamp),
                //    child:
                TabBar(
                    controller: tabController,
                    indicatorColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: _TabIndicator(),
                    labelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeights.medium,
                        letterSpacing: 1.25,
                        color: AppColors.white87),
                    unselectedLabelStyle: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(
                            fontWeight: FontWeights.medium,
                            letterSpacing: 1.25,
                            color: AppColors.white60),
                    tabs: [
                  Tab(text: CoinSpecTabs.tabIndex[0]),
                  Tab(text: CoinSpecTabs.tabIndex[1]),
                ]))
        //)
        );
  }
}

class _TabIndicator extends BoxDecoration {
  final BoxPainter _painter;

  _TabIndicator() : _painter = _TabIndicatorPainter();

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  final Paint _paint;

  _TabIndicatorPainter()
      : _paint = Paint()
          ..color = Colors.white
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    //final double _xPos = offset.dx + cfg.size!.width / 2;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(
          offset.dx,
          offset.dy + cfg.size!.height + 10,
          offset.dx + cfg.size!.width,
          offset.dy + cfg.size!.height - 2,
        ),
        topLeft: const Radius.circular(8.0),
        topRight: const Radius.circular(8.0),
      ),
      _paint,
    );
  }
}
