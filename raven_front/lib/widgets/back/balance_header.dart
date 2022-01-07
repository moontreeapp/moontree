import 'dart:async';

import 'package:flutter/material.dart';
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
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';

  @override
  void initState() {
    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
    super.initState();
    listeners.add(streams.app.holding.listen((value) {
      if (value != symbol) {
        setState(() {
          symbol = value;
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
              Text('amount',
                  style:
                      Theme.of(context).balanceAmount), // get this from balance
              SizedBox(height: 1),
              Text(visibleFiatAmount,
                  style: Theme.of(context)
                      .balanceDollar), // USD amount of balance fix!
              SizedBox(height: 30),
              widget.pageTitle == 'Send'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('Remaining:', // get from stream
                              style: Theme.of(context).remaining),
                          Text('amount', style: Theme.of(context).remaining)
                        ])
                  : SizedBox(height: 14),
            ],
          )
        ],
      ),
    );
  }
}
