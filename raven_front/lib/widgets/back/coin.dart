import 'dart:async';

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

class Coin extends StatefulWidget {
  final String symbol;
  final String pageTitle;
  final int holdingSat;
  final String? totalSupply;

  Coin({
    Key? key,
    required this.pageTitle,
    required this.symbol,
    required this.holdingSat,
    this.totalSupply,
  }) : super(key: key);

  @override
  _CoinState createState() => _CoinState();
}

class _CoinState extends State<Coin> {
  bool front = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: headerCenter(),
    );
  }

  List<Widget> headerCenter() {
    var ret = [
      GestureDetector(
        onTap: () => setState(() => front = !front),
        child: components.icons.assetAvatar(widget.symbol, size: 48),
      ),
      SizedBox(height: 9),
      selections,
      SizedBox(height: 5),
      // get this from balance
      front ? frontText : backText,
      SizedBox(height: 1),
    ];

    // make it a fixed size
    if (front && widget.pageTitle != 'Asset') {
      ret.addAll([
        // USD amount of balance fix!
        Text(
            components.text.securityAsReadable(
              widget.holdingSat,
              symbol: widget.symbol,
              asUSD: true,
            ),
            style: Theme.of(context).balanceDollar),
        //SizedBox(height: 30),
      ]);
    } else if (front && widget.totalSupply != null) {
      ret.addAll([
        Text('Total Supply', style: Theme.of(context).balanceDollar),
      ]);
    }
    return ret;
  }

  Widget get selected => Icon(Icons.circle, size: 6, color: Color(0xDEFFFFFF));
  Widget get unselected =>
      Icon(Icons.circle_outlined, size: 6, color: Color(0x99FFFFFF));

  List<Widget> get selectionList => [selected, SizedBox(width: 8), unselected];

  Widget get selections => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: front ? selectionList : selectionList.reversed.toList());

  Widget get frontText => Text(
      widget.totalSupply ??
          components.text.securityAsReadable(
            widget.holdingSat,
            symbol: widget.symbol,
            asUSD: false,
          ),
      style: Theme.of(context).balanceAmount);
  Widget get backText => Text(
        widget.symbol.toTitleCase(underscoreAsSpace: true),
        style: Theme.of(context).balanceBackText,
      );
}
