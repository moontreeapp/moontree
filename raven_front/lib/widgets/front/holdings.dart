import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';

class HoldingList extends StatefulWidget {
  final Iterable<Balance>? holdings;
  const HoldingList({this.holdings, Key? key}) : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  List<StreamSubscription> listeners = [];
  late Iterable<Balance> holdings;
  bool showUSD = false;
  Rate? rateUSD;

  @override
  void initState() {
    super.initState();
    listeners.add(
        res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where((change) =>
              change.data.address?.wallet?.accountId == Current.accountId)
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
    holdings = widget.holdings ?? Current.holdings;
    //services.balance.accountBalances(
    //        accounts.primaryIndex.getOne(widget.currentAccountId!)!)
    //    : services.balance.addressesBalances(
    //        [addresses.byAddress.getOne(widget.currentWalletAddress!)!]);
    return holdings.isEmpty // <-- on front tab...
        //? components.empty.holdings(context)
        ? Container()
        : Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 5.0),
            child: RefreshIndicator(
              child: _holdingsView(context),
              onRefresh: () => refresh(),
            ));
  }

  ListView _holdingsView(BuildContext context, {Wallet? wallet}) {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in holdings) {
      var thisHolding = ListTile(
          //dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          onTap: () {
            streams.spend.form.add(SpendForm.merge(
                form: streams.spend.form.value,
                symbol: holding.security.symbol));
            Navigator.of(components.navigator.routeContext!).pushNamed(
                holding.security.symbol == 'RVN'
                    ? '/transactions'
                    : '/transactions',
                arguments: {
                  'holding': holding,
                  'walletId': wallet?.walletId ?? null
                });
          }, // wallet transactions are on wallet screen, so remove wallet id here.
          leading: Container(
              height: 40,
              width: 40,
              child: components.icons.assetAvatar(holding.security.symbol)),
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                holding.security.symbol == 'RVN'
                    ? 'Ravencoin'
                    : holding.security.symbol,
                style: Theme.of(context).holdingName),
            Text(
                components.text.securityAsReadable(holding.value,
                    security: holding.security, asUSD: showUSD),
                style: Theme.of(context).holdingValue),
          ]),
          trailing: Icon(Icons.chevron_right_rounded));
      if (holding.security.symbol == 'RVN') {
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
