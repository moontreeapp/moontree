import 'dart:async';
import 'package:intersperse/intersperse.dart';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class SubAssetList extends StatefulWidget {
  final String symbol;

  const SubAssetList({Key? key, required this.symbol}) : super(key: key);

  @override
  State<SubAssetList> createState() => _SubAssetList();
}

class _SubAssetList extends State<SubAssetList> {
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

  List<AssetHolding> assetSubsHoldings(String asset) {
    var holdings = Current.holdings
        .where((Balance balance) => balance.security.isAsset)
        .map((Balance balance) => balance.security.symbol)
        .where((String symbol) =>
            symbol.startsWith(asset) && symbol.length > asset.length)
        .map((String symbol) => symbol.substring(asset.length, symbol.length))
        .where((String symbol) =>
            symbol.startsWith('/#') ||
            symbol.startsWith('/') ||
            symbol.startsWith('#'));
    var mains = [];
    var uniques = [];
    var qualifiers = [];
    for (var name in holdings) {
      if (name.startsWith('/#')) {
        if (name.substring(2, name.length).contains('/')) {
          var firstName = name.substring(2, name.length).split('/').first;
          qualifiers.add(firstName);
        } else {
          qualifiers.add(name.substring(2, name.length));
        }
      } else if (name.startsWith('/')) {
        if (name.substring(1, name.length).contains('/')) {
          var firstName = name.substring(1, name.length).split('/').first;
          mains.add(firstName);
        } else {
          mains.add(name.substring(1, name.length));
        }
      } else if (name.startsWith('#')) {
        uniques.add(name.substring(1, name.length));
      }
    }
    mains.toSet();
    return [
      for (var name in mains
        ..addAll(uniques)
        ..addAll(qualifiers))
        AssetHolding(
            symbol: name,
            main: mains.contains(name),
            unique: uniques.contains(name),
            qualifier: qualifiers.contains(name))
    ];
  }

  @override
  Widget build(BuildContext context) {
    assets = assetSubsHoldings(widget.symbol);
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
                children: [Text('No Sub Assets to manage. Create one!')],
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

  void navigate(String symbol, {Wallet? wallet}) {
    streams.app.asset.add(symbol);
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/manage/asset',
      arguments: {'symbol': symbol, 'walletId': wallet?.walletId ?? null},
    );
  }

  ListView _assetsView(BuildContext context, {Wallet? wallet}) => ListView(
          children: <Widget>[
        for (var asset in assets)
          ListTile(
              //dense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              onTap: () {
                if (asset.length == 1) {
                  navigate(asset.singleSymbol!, wallet: wallet);
                } else {
                  SelectionItems(
                    context,
                    names: [
                      if (asset.main) SelectionOption.Main,
                      if (asset.unique) SelectionOption.NFT,
                      if (asset.qualifier) SelectionOption.Qualifier,
                    ],
                    behaviors: [
                      if (asset.main)
                        () => navigate('${widget.symbol}/${asset.subSymbol!}',
                            wallet: wallet),
                      if (asset.unique)
                        () => navigate(asset.uniqueSymbol!, wallet: wallet),
                      if (asset.qualifier)
                        () => navigate(asset.qualifierSymbol!, wallet: wallet),
                    ],
                  ).build();
                }
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
      ].intersperse(Divider(height: 1)).toList());
}
