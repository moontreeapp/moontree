import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/application/cubits.dart';
//import '../../../pages/wallet/transactions/bloc.dart';

class CoinSpecTabs extends StatefulWidget {
  const CoinSpecTabs({
    Key? key,
    required this.cubit,
  }) : super(key: key);
  final TransactionsViewCubit cubit;

  @override
  _CoinSpecTabsState createState() => _CoinSpecTabsState();

  static List<String> tabIndex = <String>['HISTORY', 'DATA'];
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

  void changeContent() => widget.cubit.state.currentTab
      .add(CoinSpecTabs.tabIndex[tabController.index]);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: Container(
            height: 56,
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: TabBar(
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
                tabs: <Widget>[
                  Tab(text: CoinSpecTabs.tabIndex[0]),
                  Tab(text: CoinSpecTabs.tabIndex[1]),
                ])));
  }
}

class _TabIndicator extends BoxDecoration {
  _TabIndicator() : _painter = _TabIndicatorPainter();
  final BoxPainter _painter;

  @override
  BoxPainter createBoxPainter([void Function()? onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  _TabIndicatorPainter()
      : _paint = Paint()
          ..color = Colors.white
          ..isAntiAlias = true;
  final Paint _paint;

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
