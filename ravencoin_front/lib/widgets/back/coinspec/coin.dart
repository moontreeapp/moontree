import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_front/cubits/send/cubit.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/spend.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/utils/extensions.dart';

class Coin extends StatefulWidget {
  final String symbol;
  final String pageTitle;
  final int holdingSat;
  final String? totalSupply;
  final SimpleSendFormCubit? cubit;

  Coin({
    Key? key,
    required this.pageTitle,
    required this.symbol,
    required this.holdingSat,
    this.totalSupply,
    this.cubit,
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
        AnimationController(vsync: this, duration: Duration(milliseconds: 240));
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
      children: <Widget>[icon, subHeader],
    );
  }

  Widget get icon => GestureDetector(
        onTap: () async {
          if (services.developer.developerMode) {
            controller.reverse();
            await Future<void>.delayed(Duration(milliseconds: 240));
            setState(() => front = !front);
          }
        },
        child:

            /// used to push it down because we hid stuff and want to cetner:
            Column(
          children: <Widget>[
            SizedBox(height: .015.ofMediaHeight(context)),
            Hero(
              tag: widget.symbol.toLowerCase(),
              child: components.icons.assetAvatar(
                widget.symbol,
                size: .0631.ofMediaHeight(context),
                net: pros.settings.net,
              ),
            ),
          ],
        ),
      );

  Widget get subHeader =>
      FadeTransition(opacity: animation, child: Column(children: belowIcon));

  List<Widget> get belowIcon {
    var ret = [
      //SizedBox(height: 9),
      //selections,
      SizedBox(height: 5),
      // get this from balance
      front ? frontText : backText,
      SizedBox(height: 1),
    ];

    // make it a fixed size
    if (front && widget.pageTitle != 'Asset' && widget.symbol == 'RVN') {
      ret.addAll([
        // USD amount of balance fix!
        Text(
            services.conversion.securityAsReadable(
              widget.holdingSat,
              symbol: widget.symbol,
              asUSD: true,
            ),
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: AppColors.white87)),
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
    var holding = services.conversion.securityAsReadable(
      widget.holdingSat,
      symbol: widget.symbol,
      asUSD: false,
    );
    var text = Text(
      widget.totalSupply ?? holding,
      style: Theme.of(context)
          .textTheme
          .headline1!
          .copyWith(color: AppColors.white87),
    );
    return widget.pageTitle == 'Send'
        ? GestureDetector(
            child: text,
            onTap: () => widget.cubit?.set(amount: holding.toDouble()))
        : text;
  }

  Widget get backText => Text(
        widget.symbol == pros.securities.currentCoin.symbol
            ? symbolName(widget.symbol)
            : widget.symbol,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: AppColors.white),
      );
}
