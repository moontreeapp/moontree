import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';

class AssetList extends StatefulWidget {
  const AssetList({Key? key}) : super(key: key);

  @override
  State<AssetList> createState() => _AssetList();
}

class _AssetList extends State<AssetList> {
  List<StreamSubscription> listeners = [];
  late Iterable<Asset> assets;

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
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Future refresh() async {
    await services.history.produceAddressOrBalance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var holdings = Current.holdings
        .where((Balance balance) => balance.security.isAsset)
        .map((Balance balance) => balance.security.symbol);
    //var mains = holdings.where((String name) => name.contains('/')).map((String name) => name.split('/').first).where((name) => !name.startsWith('#') && !name.startsWith('\$') && !name.endsWith('!')).toList().addAll(holdings.where((String name) => !name.contains('/')));
    //var admins = holdings.map((String name) => );
    //var restricted  = holdings.map((String name) => );
    var mains = [];
    var admins = [];
    var restricteds = [];
    var qualifiers = [];
    for (var name in holdings) {
      if (name.contains('/')) {
        var firstName = name.split('/').first;
        if (firstName.startsWith('#')) {
          qualifiers.add(firstName);
        } else {
          mains.add(firstName);
        }
      } else if (name.contains('#')) {
        var firstName = name.split('#').first;
        mains.add(firstName);
      } else {
        if (name.startsWith('#')) {
          qualifiers.add(name);
        } else if (name.startsWith('\$')) {
          restricteds.add(name);
        } else if (name.endsWith('!')) {
          admins.add(name);
        } else {
          mains.add(name);
        }
      }
    }
    var cleanedAdmins =
        admins.map((name) => name.substring(0, name.length - 1));
    var cleanedRestricteds =
        restricteds.map((name) => name.substring(1, name.length));
    var cleanedQualifiers =
        qualifiers.map((name) => name.substring(1, name.length));
    for (var name in mains.toSet()
      ..addAll(cleanedAdmins)
      ..addAll(cleanedRestricteds)
      ..addAll(cleanedQualifiers)) {
      print(
          '$name ${mains.contains(name) ? 'Main' : ''} ${cleanedAdmins.contains(name) ? 'Admin' : ''} ${cleanedRestricteds.contains(name) ? 'Restricted' : ''} ${cleanedQualifiers.contains(name) ? 'Qualifier' : ''}');
    }

    //services.balance.accountBalances(
    //        accounts.primaryIndex.getOne(widget.currentAccountId!)!)
    //    : services.balance.addressesBalances(
    //        [addresses.byAddress.getOne(widget.currentWalletAddress!)!]);
    return assets.isEmpty && res.vouts.data.isEmpty // <-- on front tab...
        ? components.empty.assets(context)
        : assets.isEmpty
            ? Container(/* awaiting transactions placeholder... */)
            : Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5.0),
                child: RefreshIndicator(
                  child: _assetsView(context),
                  onRefresh: () => refresh(),
                ));
  }

  ListView _assetsView(BuildContext context, {Wallet? wallet}) {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in assets) {
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
