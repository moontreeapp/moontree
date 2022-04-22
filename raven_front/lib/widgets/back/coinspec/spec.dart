import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class CoinSpec extends StatefulWidget {
  final String pageTitle;
  final Security security;
  final Widget? bottom;
  final Color? color;

  CoinSpec({
    Key? key,
    required this.pageTitle,
    required this.security,
    this.bottom,
    this.color,
  }) : super(key: key);

  @override
  _CoinSpecState createState() => _CoinSpecState();
}

class _CoinSpecState extends State<CoinSpec> with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  double amount = 0.0;
  double holding = 0.0;
  String visibleAmount = '0';
  String visibleFiatAmount = '';

  @override
  void initState() {
    super.initState();
    listeners.add(streams.spend.form.listen((SpendForm? value) {
      if (value != null && value.amount != null && value.amount != amount) {
        if (mounted) {
          setState(() {
            amount = value.amount!;
          });
        }
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get symbol => widget.security.symbol;

  @override
  Widget build(BuildContext context) {
    var possibleHoldings = [
      for (var balance in Current.holdings)
        if (balance.security.symbol == symbol) utils.satToAmount(balance.value)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    var holdingSat = utils.amountToSat(holding);
    var amountSat = utils.amountToSat(amount);
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          utils.amountToSat(double.parse(visibleAmount)),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return Container(
      padding: EdgeInsets.only(top: 16),
      height: widget.pageTitle == 'Send' ? 209 : 201,
      color: widget.color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Coin(
              pageTitle: widget.pageTitle,
              symbol: symbol,
              holdingSat: holdingSat,
              totalSupply: widget.pageTitle == 'Asset'
                  ? res.assets.bySymbol.getOne(symbol)?.amount.toCommaString()
                  : null),
          widget.bottom ?? specBottom(holdingSat, amountSat),
        ],
      ),
    );
  }

  Widget specBottom(int holdingSat, int amountSat) {
    if (widget.pageTitle == 'Asset') {
      return AssetSpecBottom(symbol: symbol);
    }
    if (widget.pageTitle == 'Send') {
      return Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, bottom: widget.pageTitle == 'Send' ? 9 : 1),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Remaining:',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: AppColors.offWhite)),
            Text(
                components.text.securityAsReadable(holdingSat - amountSat,
                    symbol: symbol, asUSD: false),
                style: (holding - amount) >= 0
                    ? Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: AppColors.offWhite)
                    : Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: AppColors.error))
          ]));
    }
    return CoinSpecTabs();
  }
}
