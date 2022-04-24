import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

final rvn = res.securities.RVN.symbol;

class HoldingList extends StatefulWidget {
  final Iterable<Balance>? holdings;
  final ScrollController scrollController;

  const HoldingList({
    this.holdings,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  List<StreamSubscription> listeners = [];
  static bool _hideList = true;
  static bool _balanceWasEmpty = false;
  late List<AssetHolding> holdings;
  int holdingCount = 1;
  bool showUSD = false;
  bool showPath = false;
  Rate? rateUSD;
  Set<Balance> balances = {};

  @override
  void initState() {
    super.initState();
    listeners.add(res.assets.changes.listen((Change<Asset> change) {
      // if vouts in our account has changed...
      var count = res.assets.length;
      if (count > holdingCount) {
        setState(() {
          holdingCount = count;
        });
      }
    }));
    //listeners.add(
    //    res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
    //  // if vouts in our account has changed...
    //  if (batchedChanges
    //      .where(
    //          (change) => change.data.address?.wallet?.id == Current.walletId)
    //      .isNotEmpty) {
    //    setState(() {});
    //  }
    //}));
    /// don't need to pull rates to this page
    //listeners.add(res.rates.batchedChanges.listen((batchedChanges) {
    //  // ignore: todo
    //  // TODO: should probably include any assets that are in the holding of the main account too...
    //  var changes = batchedChanges.where((change) =>
    //      change.data.base == res.securities.RVN &&
    //      change.data.quote == res.securities.USD);
    //  if (changes.isNotEmpty)
    //    setState(() {
    //      rateUSD = changes.first.data;
    //    });
    //}));
    /// lets try watching balances instead
    listeners.add(streams.wallet.unspentsCallback.listen((value) async {
      if (services.download.unspents.scripthashesChecked <
          Current.wallet.addresses.length) {
        return;
      }
      setState(() {});
    }));

    listeners.add(res.balances.changes.listen((Change<Balance> change) {
      var interimBalances = res.balances.data.toSet();
      if (balances != interimBalances) {
        setState(() {
          balances = interimBalances;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  // ignore: unused_element
  void _toggleUSD() {
    setState(() {
      if (res.rates.primaryIndex
              .getOne(res.securities.RVN, res.securities.USD) ==
          null) {
        showUSD = false;
      } else {
        showUSD = !showUSD;
      }
    });
  }

  void _togglePath() {
    setState(() {
      showPath = !showPath;
    });
  }

  Future refresh() async {
    await services.rate.saveRate();
    setState(() {});
    // showing snackbar
    //_scaffoldKey.currentState.showSnackBar(
    //  SnackBar(
    //    content: const Text('Page Refreshed'),
    //  ),
    //);
  }

  @override
  Widget build(BuildContext context) {
    if (!_balanceWasEmpty) {
      _balanceWasEmpty = (widget.holdings ?? Current.holdings).isEmpty;
    }

    holdings = utils.assetHoldings(widget.holdings ??
        services.download.unspents.unspentBalances
            .where((balance) => balance.walletId == Current.walletId));

    _hideList = Current.wallet is LeaderWallet
        ? services.client.subscribe.subscriptionHandlesHistory.length <
            Current.wallet.addresses.length
        : false;
    /*
    print(services.wallet.leader
        .gapSatisfied(Current.wallet as LeaderWallet, NodeExposure.External));
    */

    return _hideList
        ? components.empty.getAssetsPlaceholder(context,
            scrollController: widget.scrollController,
            count: _balanceWasEmpty ? holdingCount : Current.holdings.length,
            holding: true)
        : //RefreshIndicator( child:
        _holdingsView(context);

    //  onRefresh: () => refresh(),
    //);
  }

  void navigate(Balance balance, {Wallet? wallet}) {
    streams.app.wallet.asset.add(balance.security.symbol);
    streams.spend.form.add(SpendForm.merge(
        form: streams.spend.form.value, symbol: balance.security.symbol));
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transactions',
      arguments: {'holding': balance, 'walletId': wallet?.id ?? null},
    );
  }

  ListView _holdingsView(BuildContext context, {Wallet? wallet}) {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in holdings) {
      var thisHolding = ListTile(
        //dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        onTap: () => onTap(wallet, holding),
        onLongPress: _togglePath,
        leading: leadingIcon(holding),
        title: title(holding), /*trailing: Icon(Icons.chevron_right_rounded)*/
      );
      if (holding.symbol == rvn) {
        rvnHolding.add(thisHolding);
        rvnHolding.add(Divider(height: 1));

        /// create asset should allow you to create an asset using a speicific address...
        // hide create asset button - not beta
        //if (holding.value < 600) {
        //  rvnHolding.add(ListTile(
        //      onTap: () {},
        //      title: Text('+ Create Asset (not enough RVN)',
        //          style: TextStyle(color: Theme.of(context).disabledColor))));
        //} else {
        //  rvnHolding.add(ListTile(
        //      onTap: () {},
        //      title: TextButton.icon(
        //          onPressed: () => Navigator.pushNamed(context, '/transaction/create',
        //            arguments: {'walletId': wallet?.walletId ?? null}),
        //          icon: Icon(Icons.add),
        //          label: Text('Create Asset'))));
        //}
      } else {
        assetHoldings.add(thisHolding);
        assetHoldings.add(Divider(height: 1));
      }
    }
    if (rvnHolding.isEmpty) {
      rvnHolding.add(Shimmer.fromColors(
              baseColor: AppColors.primaries[0],
              highlightColor: Colors.white,
              child: components.empty.assetPlaceholder(context, holding: true))
          //ListTile(
          ////dense: true,
          //contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          //onTap: () {},
          //leading: Container(
          //    height: 50,
          //    width: 50,
          //    child: components.icons.assetAvatar(res.securities.RVN.symbol)),
          //title: Text(res.securities.RVN.symbol,
          //    style: Theme.of(context).textTheme.bodyText1),)
          );
      rvnHolding.add(Divider(height: 1));
      //rvnHolding.add(ListTile(
      //    onTap: () {},
      //    title: Text('+ Create Asset (not enough RVN)',
      //        style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(
        controller: widget.scrollController,
        dragStartBehavior: DragStartBehavior.start,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          ...rvnHolding,
          ...assetHoldings,
          ...[components.empty.blankNavArea(context)]
        ]);
  }

  void onTap(Wallet? wallet, AssetHolding holding) {
    if (holding.length == 1) {
      navigate(holding.balance!, wallet: wallet);
    } else {
      SelectionItems(
        context,
        symbol: holding.symbol,
        names: [
          if (holding.main != null) SelectionOption.Main,
          if (holding.sub != null) SelectionOption.Sub,
          if (holding.subAdmin != null) SelectionOption.Sub_Admin,
          if (holding.admin != null) SelectionOption.Admin,
          if (holding.restricted != null) SelectionOption.Restricted,
          if (holding.restrictedAdmin != null) SelectionOption.Restricted_Admin,
          if (holding.qualifier != null) SelectionOption.Qualifier,
          if (holding.qualifierSub != null) SelectionOption.Sub_Qualifier,
          if (holding.nft != null) SelectionOption.NFT,
          if (holding.channel != null) SelectionOption.Channel,
        ],
        behaviors: [
          if (holding.main != null)
            () => navigate(holding.main!, wallet: wallet),
          if (holding.sub != null)
            () => navigate(holding.sub!, wallet: wallet), /////
          if (holding.subAdmin != null)
            () => navigate(holding.subAdmin!, wallet: wallet),
          if (holding.admin != null)
            () => navigate(holding.admin!, wallet: wallet),
          if (holding.restricted != null)
            () => navigate(holding.restricted!, wallet: wallet),
          if (holding.restrictedAdmin != null)
            () => navigate(holding.restrictedAdmin!, wallet: wallet),
          if (holding.qualifier != null)
            () => navigate(holding.qualifier!, wallet: wallet),
          if (holding.qualifierSub != null)
            () => navigate(holding.qualifierSub!, wallet: wallet),
          if (holding.nft != null)
            () => navigate(holding.nft!, wallet: wallet), /////
          if (holding.channel != null)
            () => navigate(holding.channel!, wallet: wallet),
        ],
        values: [
          if (holding.main != null)
            components.text.securityAsReadable(
              holding.main!.value,
              security: holding.main!.security,
              asUSD: showUSD,
            ),
          if (holding.sub != null)
            components.text.securityAsReadable(
              holding.sub!.value,
              security: holding.sub!.security,
              asUSD: showUSD,
            ),
          if (holding.subAdmin != null)
            components.text.securityAsReadable(
              holding.subAdmin!.value,
              security: holding.subAdmin!.security,
              asUSD: showUSD,
            ),
          if (holding.admin != null)
            components.text.securityAsReadable(
              holding.admin!.value,
              security: holding.admin!.security,
              asUSD: showUSD,
            ),
          if (holding.restricted != null)
            components.text.securityAsReadable(
              holding.restricted!.value,
              security: holding.restricted!.security,
              asUSD: showUSD,
            ),
          if (holding.restrictedAdmin != null)
            components.text.securityAsReadable(
              holding.restrictedAdmin!.value,
              security: holding.restrictedAdmin!.security,
              asUSD: showUSD,
            ),
          if (holding.qualifier != null)
            components.text.securityAsReadable(
              holding.qualifier!.value,
              security: holding.qualifier!.security,
              asUSD: showUSD,
            ),
          if (holding.qualifierSub != null)
            components.text.securityAsReadable(
              holding.qualifierSub!.value,
              security: holding.qualifierSub!.security,
              asUSD: showUSD,
            ),
          if (holding.nft != null)
            components.text.securityAsReadable(
              holding.nft!.value,
              security: holding.nft!.security,
              asUSD: showUSD,
            ),
          if (holding.channel != null)
            components.text.securityAsReadable(
              holding.channel!.value,
              security: holding.channel!.security,
              asUSD: showUSD,
            ),
        ],
      ).build();
    }
  }

  Widget leadingIcon(AssetHolding holding) => Container(
      height: 40,
      width: 40,
      child: components.icons.assetAvatar(holding.admin != null
          ? holding.adminSymbol!
          : holding.restricted != null
              ? holding.restrictedSymbol!
              : holding.qualifier != null
                  ? holding.qualifierSymbol!
                  : holding.channel != null
                      ? holding.channelSymbol!
                      : holding.nft != null
                          ? holding.nftSymbol!
                          : holding.subAdmin != null
                              ? holding.subAdminSymbol!
                              : holding.sub != null
                                  ? holding.subSymbol!
                                  : holding.qualifierSub != null
                                      ? holding.qualifierSubSymbol!
                                      : holding.symbol));

  Widget title(AssetHolding holding) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              width: MediaQuery.of(context).size.width - (16 + 40 + 16 + 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(holding.symbol == rvn ? 'Ravencoin' : holding.last,
                    style: Theme.of(context).textTheme.bodyText1),
              ))
          /* //this feature can show the path 
          if (holding.symbol != holding.last && showPath)
            holding.last.length >= 20
                ? Text('  (...)', style: Theme.of(context).textTheme.caption)
                : Text('   (' + holding.notLast + ')',
                    style: Theme.of(context).textTheme.caption),
                    */
        ]),
        Text(
            holding.mainLength > 1 && holding.restricted != null
                ? [
                    if (holding.main != null) 'Main',
                    if (holding.admin != null) 'Admin',
                    if (holding.restricted != null) 'Restricted',
                    if (holding.restrictedAdmin != null) 'Restricted Admin',
                  ].join(', ')
                : components.text.securityAsReadable(
                    holding.balance?.value ?? 0,
                    security: holding.balance?.security ??
                        Security(
                            symbol: 'unknown', securityType: SecurityType.Fiat),
                    asUSD: showUSD),
            style: Theme.of(context).textTheme.bodyText2),
      ]);
}
