import 'dart:async';
import 'package:intersperse/intersperse.dart';

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
  late Iterable<AssetHolding> assets;

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

  List<AssetHolding> assetHoldings() {
    var holdings = Current.holdings
        .where((Balance balance) => balance.security.isAsset)
        .map((Balance balance) => balance.security.symbol);
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
    var cleanedMains = mains.toSet();
    var cleanedAdmins =
        admins.map((name) => name.substring(0, name.length - 1));
    var cleanedRestricteds =
        restricteds.map((name) => name.substring(1, name.length));
    var cleanedQualifiers =
        qualifiers.map((name) => name.substring(1, name.length));
    return [
      for (var name in cleanedMains
        ..addAll(cleanedAdmins)
        ..addAll(cleanedRestricteds)
        ..addAll(cleanedQualifiers))
        AssetHolding(
            symbol: name,
            main: cleanedMains.contains(name),
            admin: cleanedAdmins.contains(name),
            restricted: cleanedRestricteds.contains(name),
            qualifier: cleanedQualifiers.contains(name))
    ];
  }

  @override
  Widget build(BuildContext context) {
    assets = assetHoldings();
    return assets.isEmpty && res.vouts.data.isEmpty // <-- on front tab...
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('This is where assets you can manage will show up...')
            ],
          ) //components.empty.assets(context)
        : assets.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text('No assets to manage. Create one!')],
              ) //components.empty.assets(context)
            : Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5.0),
                child: RefreshIndicator(
                  child: _assetsView(context),
                  onRefresh: () => refresh(),
                ));
  }

  ListView _assetsView(BuildContext context, {Wallet? wallet}) => ListView(
          children: <Widget>[
        for (var asset in assets)
          ListTile(
              //dense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              onTap: () {
                //streams.spend.form.add(SpendForm.merge(
                //    form: streams.spend.form.value, symbol: asset.symbol));
                //Navigator.of(components.navigator.routeContext!).pushNamed(
                //    asset.symbol == 'RVN' ? '/transactions' : '/transactions',
                //    arguments: {
                //      'holding': holding,
                //      'walletId': wallet?.walletId ?? null
                //    });
              }, // wallet transactions are on wallet screen, so remove wallet id here.
              leading: Container(
                  height: 40,
                  width: 40,
                  child: components.icons.assetAvatar(asset.symbol)),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.symbol, style: Theme.of(context).holdingName),
                    Text(
                        (asset.main ? 'Main ' : '') +
                            (asset.admin ? 'Admin ' : '') +
                            (asset.restricted ? 'Restricted ' : '') +
                            (asset.restricted ? 'Qualifier ' : ''),
                        style: Theme.of(context).holdingValue),
                  ]),
              trailing: Icon(Icons.chevron_right_rounded))
      ].intersperse(Divider()).toList());
}

class AssetHolding {
  final String symbol;
  final bool main;
  final bool admin;
  final bool restricted;
  final bool qualifier;
  AssetHolding({
    required this.symbol,
    this.main = false,
    this.admin = false,
    this.restricted = false,
    this.qualifier = false,
  });
}
