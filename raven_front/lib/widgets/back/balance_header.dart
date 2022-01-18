import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:tuple/tuple.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class BalanceHeader extends StatefulWidget {
  final String pageTitle;
  BalanceHeader({Key? key, required this.pageTitle}) : super(key: key);

  @override
  _BalanceHeaderState createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader>
    with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  String symbol = 'RVN';
  double amount = 0.0;
  double holding = 0.0;
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';

  @override
  void initState() {
    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
    super.initState();
    components.navigator.tabController = components.navigator.tabController ??
        TabController(length: 2, vsync: this);
    listeners.add(streams.app.spending.symbol.listen((String value) {
      print(symbol);
      print(value);
      if (value == 'Ravencoin') {
        value = 'RVN';
      }
      if (symbol != value) {
        setState(() {
          symbol = value;
        });
      }
    }));
    listeners.add(streams.app.spending.amount.listen((double value) {
      if (amount != value) {
        setState(() {
          amount = value;
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

  @override
  Widget build(BuildContext context) {
    var possibleHoldings = [
      for (var balance in
          //      useWallet
          //      ? Current.walletHoldings(data['walletId'])
          //      :
          Current.holdings)
        if (balance.security.symbol == symbol) satToAmount(balance.confirmed)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    //var divisibility = assets.bySymbol.getOne(symbol)?.divisibility ?? 8;
    var divisibility = 8;
    var holdingSat = amountToSat(holding, divisibility: divisibility);
    var amountSat = amountToSat(amount,
        divisibility: assets.bySymbol.getOne(symbol)?.divisibility ?? 8);
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          amountToSat(double.parse(visibleAmount), divisibility: divisibility),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: ListView(
        shrinkWrap: true,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              components.icons.assetAvatar(symbol, height: 56, width: 56),
              SizedBox(height: 8),
              // get this from balance
              Text(
                  components.text.securityAsReadable(holdingSat,
                      symbol: symbol, asUSD: false),
                  style: Theme.of(context).balanceAmount),
              SizedBox(height: 1),
              // USD amount of balance fix!
              Text(
                  components.text.securityAsReadable(holdingSat,
                      symbol: symbol, asUSD: true),
                  style: Theme.of(context).balanceDollar),
              SizedBox(height: 30),
              widget.pageTitle == 'Send'
                  ? Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Remaining:',
                                style: Theme.of(context).remaining),
                            Text(
                                components.text.securityAsReadable(
                                    holdingSat - amountSat,
                                    symbol: symbol,
                                    asUSD: false),
                                //(holding - amount).toString(),
                                style: (holding - amount) >= 0
                                    ? Theme.of(context).remaining
                                    : Theme.of(context).remainingRed)
                          ]))
                  //: SizedBox(height: 14+16),
                  : TabBar(
                      controller: components.navigator.tabController,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: _TabIndicator(),
                      /* 
                      ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                            side: BorderSide(
                                color: Color(0xDD613896), width: 8.0),
                          ),
                          color: Colors.red
                          ),
 */
/*                           UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.white, width: 8.0),
                        insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      ),
 */
                      /* use a back container with a fill white, 
                          height of 16dp 
                          and then curve the corner by 8dp.
                          oh and then offset it by 2dp in Y direction */
                      tabs: [Tab(text: 'Transactions'), Tab(text: 'Metadata')]),
            ],
          )
        ],
      ),
    );
  }
}

/* TabBar(
                  tabs: [Tab(text: 'Transactions'), Tab(text: 'Metadata')]))));

DefaultTabController(
        length: 2,
        child:...TabBarView(children: <Widget>[]) */

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
