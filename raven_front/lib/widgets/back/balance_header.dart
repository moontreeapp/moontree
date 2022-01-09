import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

class _BalanceHeaderState extends State<BalanceHeader> {
  List<StreamSubscription> listeners = [];
  String symbol = 'RVN';
  double amount = 0.0;
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';

  @override
  void initState() {
    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
    super.initState();
    listeners.add(streams.app.spending.symbol.listen((String value) {
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
    var divisibility = 8; /* get asset divisibility...*/
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          amountToSat(
            double.parse(visibleAmount),
            divisibility: divisibility,
          ),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    var balance = 0;
    return Container(
      padding: EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Image.asset('assets/rvnonly.png', height: 56, width: 56),
              ///symbol image placeholder
              Container(height: 56, width: 56, child: Text(symbol)),
              SizedBox(height: 8),
              // get this from balance
              Text('Balance', style: Theme.of(context).balanceAmount),
              SizedBox(height: 1),
              // USD amount of balance fix!
              Text('\$ USD Balance', style: Theme.of(context).balanceDollar),
              SizedBox(height: 30),
              widget.pageTitle == 'Send'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('Remaining:',
                              style: Theme.of(context).remaining),
                          Text((balance - amount).toString(),
                              style: Theme.of(context).remaining)
                        ])
                  : SizedBox(height: 14),
            ],
          )
        ],
      ),
    );
  }
}
