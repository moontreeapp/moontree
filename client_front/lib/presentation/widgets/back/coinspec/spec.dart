import 'package:client_back/server/src/protocol/protocol.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:wallet_utils/wallet_utils.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/components/components.dart';

class CoinSpec extends StatefulWidget {
  final String pageTitle;
  final Security security;
  final Widget? bottom;
  final Color? color;
  final SimpleSendFormCubit? cubit;
  final BalanceView balanceView;

  const CoinSpec({
    Key? key,
    required this.pageTitle,
    required this.security,
    required this.balanceView,
    this.bottom,
    this.color,
    this.cubit,
  }) : super(key: key);

  @override
  _CoinSpecState createState() => _CoinSpecState();
}

class _CoinSpecState extends State<CoinSpec> with TickerProviderStateMixin {
  double amount = 0.0;
  double holding = 0.0;
  String visibleAmount = '0';
  String visibleFiatAmount = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get symbol => widget.security.symbol;

  @override
  Widget build(BuildContext context) {
    // TODO: we have to pull this from the server, not from balance.
    //final Balance? holdingBalance = widget.security.balance;
    final Balance holdingBalance = Balance(
        walletId: Current.walletId,
        security: widget.security,
        confirmed: widget.balanceView.sats,
        unconfirmed: 0);
    int holdingSat = 0;
    if (holdingBalance != null) {
      holding = holdingBalance.amount;
      holdingSat = holdingBalance.value;
    }
    int amountSat = amount.asSats;
    if (holding - amount == 0) {
      amountSat = holdingSat;
    }
    try {
      visibleFiatAmount = services.conversion.securityAsReadable(
          double.parse(visibleAmount).asSats,
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    //return flutter_bloc.BlocBuilder<HoldingsViewCubit, HoldingsViewState>(
    //   //bloc: cubit..enter(),
    //    builder: (BuildContext context, HoldingsViewState state) {
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
        children: <Widget>[
          Coin(
              cubit: widget.cubit,
              pageTitle: widget.pageTitle,
              symbol: symbol,
              holdingSat: holdingSat,
              totalSupply: widget.pageTitle == 'Asset'
                  ? pros.assets.primaryIndex
                      .getOne(symbol, pros.settings.chain, pros.settings.net)
                      ?.amount
                      .toSatsCommaString()
                  : null),
          widget.bottom ?? specBottom(holdingSat, amountSat),
        ],
      ),
    );
    //});
  }

  Widget specBottom(int holdingSat, int amountSat) {
    if (widget.pageTitle == 'Asset') {
      return AssetSpecBottom(symbol: symbol);
    }
    if (widget.cubit != null && widget.pageTitle == 'Send') {
      return Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, bottom: widget.pageTitle == 'Send' ? 9 : 1),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Remaining:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: AppColors.offWhite)),
                Text(
                    services.conversion.securityAsReadable(
                        holdingSat - widget.cubit!.state.sats,
                        symbol: symbol),
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
