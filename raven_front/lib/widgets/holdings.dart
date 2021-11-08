import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/theme/extensions.dart';

class HoldingList extends StatefulWidget {
  final String? currentAccountId;
  final String? currentWalletId;
  final String? currentWalletAddress;
  const HoldingList(
      {this.currentAccountId,
      this.currentWalletId,
      this.currentWalletAddress,
      Key? key})
      : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  //widget.currentAccountId //  we don't rebuild on this, we're given it.
  List<StreamSubscription> listeners = [];
  late Iterable<Balance> holdings;
  bool showUSD = false;
  Rate? rateUSD;

  @override
  void initState() {
    super.initState();
    listeners
        .add(vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where((change) =>
              change.data.address?.wallet?.accountId == widget.currentAccountId)
          .isNotEmpty) {
        setState(() {});
      }
    }));
    listeners.add(rates.batchedChanges.listen((batchedChanges) {
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.data.base == securities.RVN &&
          change.data.quote == securities.USD);
      if (changes.isNotEmpty)
        setState(() {
          rateUSD = changes.first.data;
        });
    }));
  }

  @override
  void dispose() {
    //This method must not be called after dispose has been called. ??
    //currentTheme.removeListener(() {});
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  void _toggleUSD() {
    setState(() {
      if (rates.primaryIndex.getOne(securities.RVN, securities.USD) == null) {
        showUSD = false;
      } else {
        showUSD = !showUSD;
      }
    });
  }

  Future refresh() async {
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
    holdings = widget.currentAccountId != null
        ? services.balance.accountBalances(
            accounts.primaryIndex.getOne(widget.currentAccountId!)!)
        : services.balance.addressesBalances(
            [addresses.byAddress.getOne(widget.currentWalletAddress!)!]);
    return holdings.isEmpty
        ? components.empty.holdings(context)
        : Container(
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
          onTap: () => Navigator.pushNamed(context,
                  holding.security.symbol == 'RVN' ? '/transactions' : '/asset',
                  arguments: {
                    'holding': holding,
                    'walletId': wallet?.walletId ?? null
                  }), // wallet transactions are on wallet screen, so remove wallet id here.
          onLongPress: _toggleUSD,
          leading: Container(
              height: 50,
              width: 50,
              child: components.icons.assetAvatar(holding.security.symbol)),
          title: Text(holding.security.symbol,
              style: holding.security.symbol == 'RVN'
                  ? Theme.of(context).textTheme.bodyText1
                  : Theme.of(context).textTheme.bodyText2),
          trailing: Text(
              components.text.securityAsReadable(holding.value,
                  security: holding.security, asUSD: showUSD),
              style: TextStyle(color: Theme.of(context).good)));
      if (holding.security.symbol == 'RVN') {
        rvnHolding.add(thisHolding);

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
        //          onPressed: () => Navigator.pushNamed(context, '/create',
        //            arguments: {'walletId': wallet?.walletId ?? null}),
        //          icon: Icon(Icons.add),
        //          label: Text('Create Asset'))));
        //}
      } else {
        assetHoldings.add(thisHolding);
      }
    }
    if (rvnHolding.isEmpty) {
      rvnHolding.add(ListTile(
          onTap: () {},
          onLongPress: _toggleUSD,
          title: Text('RVN', style: Theme.of(context).textTheme.bodyText1),
          trailing: Text(showUSD ? '\$ 0' : '0',
              style: TextStyle(color: Theme.of(context).fine)),
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
