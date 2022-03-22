import 'dart:async';

import 'package:raven_front/theme/theme.dart';
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

class _CoinState extends State<Coin> with SingleTickerProviderStateMixin {
  bool front = true;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 960));
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.forward();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [icon, subHeader],
    );
  }

  Widget get icon => GestureDetector(
        onTap: () {
          controller.reset();
          controller.duration = Duration(milliseconds: 160);
          setState(() {
            front = !front;
            controller.forward();
          });
        },
        child: components.icons.assetAvatar(widget.symbol, size: 48),
      );

  Widget get subHeader =>
      FadeTransition(opacity: animation, child: Column(children: belowIcon));

  List<Widget> get belowIcon {
    var ret = [
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
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: AppColors.white)),
        //SizedBox(height: 30),
      ]);
    } else if (front && widget.totalSupply != null) {
      ret.addAll([
        Text('Total Supply',
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: AppColors.white)),
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

  Widget get frontText {
    var holding = components.text.securityAsReadable(
      widget.holdingSat,
      symbol: widget.symbol,
      asUSD: false,
    );
    var text = Text(
      widget.totalSupply ?? holding,
      style: Theme.of(context)
          .textTheme
          .headline1!
          .copyWith(color: AppColors.white),
    );
    return widget.pageTitle == 'Send'
        ? GestureDetector(
            child: text,
            onTap: () => streams.spend.form.add(SpendForm.merge(
                form: streams.spend.form.value, amount: holding.toDouble())))
        : text;
  }

  Widget get backText => Text(
        widget.symbol == 'RVN' ? 'Ravencoin' : widget.symbol,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: AppColors.white),
      );
}
