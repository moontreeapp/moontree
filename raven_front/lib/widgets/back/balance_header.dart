import 'dart:async';

import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class BalanceHeader extends StatefulWidget {
  final String pageTitle;
  final Color? background;
  BalanceHeader({Key? key, required this.pageTitle, this.background})
      : super(key: key);

  @override
  _BalanceHeaderState createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader>
    with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  String symbolSend = 'RVN';
  String symbolTransactions = 'RVN';
  String symbolManage = 'RVN';
  double amount = 0.0;
  double holding = 0.0;
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';

  @override
  void initState() {
    super.initState();
    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
    components.navigator.tabController = components.navigator.tabController ??
        TabController(length: 2, vsync: this);
    listeners.add(streams.spend.form.listen((SpendForm? value) {
      if (symbolSend !=
              (value?.symbol == 'Ravencoin' ? 'RVN' : value?.symbol ?? 'RVN') ||
          amount != (value?.amount ?? 0.0)) {
        setState(() {
          symbolSend =
              (value?.symbol == 'Ravencoin' ? 'RVN' : value?.symbol ?? 'RVN');
          amount = (value?.amount ?? 0.0);
        });
      }
    }));
    listeners.add(streams.app.manage.asset.listen((String? value) {
      if (streams.app.context.value == AppContext.manage &&
          symbolManage != value &&
          value != null) {
        setState(() {
          symbolManage = value;
        });
      }
    }));
    listeners.add(streams.app.wallet.asset.listen((String? value) {
      if (streams.app.context.value == AppContext.wallet &&
          symbolTransactions != value &&
          value != null) {
        setState(() {
          symbolTransactions = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    Backdrop.of(components.navigator.routeContext!).concealBackLayer();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  String get symbol => streams.app.context.value == AppContext.wallet
      ? streams.app.page.value == 'Send'
          ? symbolSend
          : symbolTransactions
      : streams.app.context.value == AppContext.manage
          ? symbolManage
          : symbolTransactions;

  @override
  Widget build(BuildContext context) {
    var possibleHoldings = [
      for (var balance in
          //      useWallet
          //      ? Current.walletHoldings(data['walletId'])
          //      :
          Current.holdings)
        if (balance.security.symbol == symbol)
          utils.satToAmount(balance.confirmed)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    //var divisibility = assets.bySymbol.getOne(symbol)?.divisibility ?? 8;
    var divisibility = 8;
    var holdingSat = utils.amountToSat(holding, divisibility: divisibility);
    var amountSat = utils.amountToSat(amount,
        divisibility: res.assets.bySymbol.getOne(symbol)?.divisibility ?? 8);
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          utils.amountToSat(double.parse(visibleAmount),
              divisibility: divisibility),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    var assetDetails;
    var totalSupply;
    if (widget.pageTitle == 'Asset') {
      assetDetails = widget.pageTitle == 'Asset'
          ? res.assets.bySymbol.getOne(symbol)
          : null;
      if (assetDetails != null) {
        totalSupply = utils
            .satToAmount(assetDetails!.satsInCirculation,
                divisibility: assetDetails!.divisibility)
            .toCommaString();
      }
    }
    return Container(
      padding: EdgeInsets.only(top: 16),
      height: 201,
      color: widget.background ?? Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Coin(
              pageTitle: widget.pageTitle,
              symbol: symbol,
              holdingSat: holdingSat,
              totalSupply: totalSupply),
          headerBottom(holdingSat, amountSat),
        ],
      ),
    );
  }

  Widget headerBottom(int holdingSat, int amountSat) {
    if (widget.pageTitle == 'Asset') {
      return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 1),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            symbol.contains('/')
                ? Text('$symbol/', style: Theme.of(context).remaining)
                : Container(),
          ]));
      //: SizedBox(height: 14+16),
    }
    if (widget.pageTitle == 'Send') {
      return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 1),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Remaining:', style: Theme.of(context).remaining),
            Text(
                components.text.securityAsReadable(holdingSat - amountSat,
                    symbol: symbol, asUSD: false),
                //(holding - amount).toString(),
                style: (holding - amount) >= 0
                    ? Theme.of(context).remaining
                    : Theme.of(context).remainingRed)
          ]));
      //: SizedBox(height: 14+16),
    }
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: TabBar(
            controller: components.navigator.tabController,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: _TabIndicator(),
            labelStyle: Theme.of(context).tabName,
            unselectedLabelStyle: Theme.of(context).tabNameInactive,
            tabs: [Tab(text: 'HISTORY'), Tab(text: 'DATA')]));
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
    final double _xPos = offset.dx + cfg.size!.width / 2;

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
