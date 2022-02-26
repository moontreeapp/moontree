import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class HoldingList extends StatefulWidget {
  final Iterable<Balance>? holdings;
  const HoldingList({this.holdings, Key? key}) : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  List<StreamSubscription> listeners = [];
  late Map<String, AssetHolding> holdings;
  bool showUSD = false;
  Rate? rateUSD;

  @override
  void initState() {
    super.initState();
    listeners.add(
        res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where(
              (change) => change.data.address?.wallet?.id == Current.walletId)
          .isNotEmpty) {
        setState(() {});
      }
    }));
    listeners.add(res.rates.batchedChanges.listen((batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.data.base == res.securities.RVN &&
          change.data.quote == res.securities.USD);
      if (changes.isNotEmpty)
        setState(() {
          rateUSD = changes.first.data;
        });
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

  Future refresh() async {
    await services.history.produceAddressOrBalance();
    await services.rate.saveRate();
    await services.balance.recalculateAllBalances();
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
    holdings = utils.assetHoldings(widget.holdings ?? Current.holdings);
    return holdings.isEmpty && res.vouts.data.isEmpty // <-- on front tab...
        ? components.empty.holdings(context)
        : holdings.isEmpty
            ? Container(/* awaiting transactions placeholder... */)
            : Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5.0),
                child: RefreshIndicator(
                  child: _holdingsView(context),
                  onRefresh: () => refresh(),
                ));
  }

  void navigate(Balance balance, {Wallet? wallet}) {
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
    var handled = []; // skip these.
    for (var balance in Current.holdings) {
      var baseSymbol =
        balance.security.asset?.baseSymbol ?? balance.security.symbol;
      var assetType =
        balance.security.asset?.assetType ?? balance.security.securityType;
      if ([
        AssetType.Main,
        AssetType.Admin,
        AssetType.Restricted,
        AssetType.RestrictedAdmin,].contains(assetType)) {
          // combine based on some more logic
          //var indicatorIcon = 
      } else if (assetType == AssetType.Sub) {
        // if you own the admin too make the icon with the sub and combine
        // if you don't just make it
      } else if (assetType == AssetType.SubAdmin) {
        // if you own the sub do nothing
        // if you don't own the sub make it and display it
      } else {
        // just make it (qualifier, sub qualifider, nft channel)
      }























    Current.holdings
    for (var holding in holdings.values) {
      if (
        holding.main != null ||
        holding.admin != null ||
        holding.restricted != null 
        /*|| holding.restrictedAdmin*/){
      var thisHolding = ListTile(
          //dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          onTap: () {
            if (holding.length == 1) {
              navigate(holding.balance!, wallet: wallet);
            } else {
              SelectionItems(
                context,
                symbol: holding.symbol,
                names: [
                  if (holding.main != null) SelectionOption.Main,
                  // NEED SUB
                  if (holding.admin != null) SelectionOption.Admin,
                  if (holding.restricted != null) SelectionOption.Restricted,
                  // NEED RESTRICTED ADMIN
                  if (holding.qualifier != null) SelectionOption.Qualifier,
                  // NEED SUBQUALIFIER
                  if (holding.unique != null) SelectionOption.NFT,
                  if (holding.channel != null) SelectionOption.Channel,
                ],
                behaviors: [
                  if (holding.main != null)
                    () => navigate(holding.main!, wallet: wallet),
                  if (holding.admin != null)
                    () => navigate(holding.admin!, wallet: wallet),
                  if (holding.restricted != null)
                    () => navigate(holding.restricted!, wallet: walbin let),
                  if (holding.qualifier != null)
                    () => navigate(holding.qualifier!, wallet: wallet),
                  if (holding.unique != null)
                    () => navigate(holding.unique!, wallet: wallet),
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
                  if (holding.qualifier != null)
                    components.text.securityAsReadable(
                      holding.qualifier!.value,
                      security: holding.qualifier!.security,
                      asUSD: showUSD,
                    ),
                  if (holding.unique != null)
                    components.text.securityAsReadable(
                      holding.unique!.value,
                      security: holding.unique!.security,
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
          }, // wallet transactions are on wallet screen, so remove wallet id here.
          leading: Container(
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
                              : holding.unique != null
                                  ? holding.uniqueSymbol!
                                  : holding.symbol)),
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(holding.symbol == 'RVN' ? 'Ravencoin' : holding.symbol,
                  style: Theme.of(context).holdingName),

              /// replaced by admin icon as default
              //holding.length > 1
              //    ? Text('•' * (holding.length - 1),
              //        //(holding.admin != null ? '•' : '') +
              //        //    (holding.restricted != null ? '•' : '') +
              //        //    (holding.qualifier != null ? '•' : '') +
              //        //    (holding.unique != null ? '•' : '') +
              //        //    (holding.channel != null ? '•' : ''),
              //        style: Theme.of(context).holdingValue)
              //    : SizedBox(width: 1),
            ]),
            Text(
                components.text.securityAsReadable(holding.balance!.value,
                    security: holding.balance!.security, asUSD: showUSD),
                style: Theme.of(context).holdingValue),
          ]),
          trailing: Icon(Icons.chevron_right_rounded));
      } 
      if(holding.qualifier != null){


      } 
      if(holding.unique != null){


      } 
      if(holding.channel != null){


      }
      if (holding.symbol == 'RVN') {
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
      rvnHolding.add(ListTile(
          onTap: () {},
          title: Text('RVN', style: Theme.of(context).holdingName),
          trailing: Text(showUSD ? '\$ 0' : '0',
              style: Theme.of(context).holdingValue),
          leading: Container(
              height: 50,
              width: 50,
              child: components.icons.assetAvatar('RVN'))));
      //rvnHolding.add(ListTile(
      //    onTap: () {},
      //    title: Text('+ Create Asset (not enough RVN)',
      //        style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(children: <Widget>[...rvnHolding, ...assetHoldings]);
  }
}
