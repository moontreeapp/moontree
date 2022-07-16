import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/spend.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

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
      padding: EdgeInsets.only(top: .021.ofMediaHeight(context)),
      //height: widget.pageTitle == 'Send' ? 209 : 201,
      height: widget.pageTitle == 'Send'
          ? 0.2588963963963964.ofMediaHeight(context)
          : 0.2489864864864865.ofMediaHeight(context),
      //height: 201.ofMediaHeight(context),
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
                  ? pros.assets.bySymbol.getOne(symbol)?.amount.toCommaString()
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
    //return CoinSpecTabs();
    return Container();
  }
}
