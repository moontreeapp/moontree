import 'dart:async';
import 'package:intersperse/intersperse.dart';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class AssetList extends StatefulWidget {
  const AssetList({Key? key}) : super(key: key);

  @override
  State<AssetList> createState() => _AssetList();
}

class _AssetList extends State<AssetList> {
  List<StreamSubscription> listeners = [];
  late Map<String, AssetHolding> assets;

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

  Map<String, AssetHolding> assetHoldings({bool assetsOnly = false}) {
    var holdings = assetsOnly
        ? Current.holdings.where((Balance balance) => balance.security.isAsset)
        : Current.holdings;
    Map<String, AssetHolding> balances = {};
    for (var balance in holdings) {
      var baseSymbol =
          balance.security.asset?.baseSymbol ?? balance.security.symbol;
      var assetType =
          balance.security.asset?.assetType ?? balance.security.securityType;
      if (!balances.containsKey(baseSymbol)) {
        balances[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          main: assetType == AssetType.Main ? balance : null,
          admin: assetType == AssetType.Admin ? balance : null,
          restricted: assetType == AssetType.Restricted ? balance : null,
          qualifier: assetType == AssetType.Qualifier ? balance : null,
          unique: assetType == AssetType.NFT ? balance : null,
          channel: assetType == AssetType.Channel ? balance : null,
          crypto: assetType == SecurityType.Crypto ? balance : null,
          fiat: assetType == SecurityType.Fiat ? balance : null,
        );
      } else {
        balances[baseSymbol] = AssetHolding.fromAssetHolding(
          balances[baseSymbol]!,
          main: assetType == AssetType.Main ? balance : null,
          admin: assetType == AssetType.Admin ? balance : null,
          restricted: assetType == AssetType.Restricted ? balance : null,
          qualifier: assetType == AssetType.Qualifier ? balance : null,
          unique: assetType == AssetType.NFT ? balance : null,
          channel: assetType == AssetType.Channel ? balance : null,
          crypto: assetType == SecurityType.Crypto ? balance : null,
          fiat: assetType == SecurityType.Fiat ? balance : null,
        );
      }
    }
    return balances;
  }

  Map<String, AssetHolding> filterToAdminAssets(
    Map<String, AssetHolding> assets,
  ) {
    assets.removeWhere((key, balance) => balance.admin == null);
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    assets = filterToAdminAssets(assetHoldings());
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
                children: [Text('No Assets to manage. Create one!')],
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

  ListView _assetsView(BuildContext context, {Wallet? wallet}) =>
      ListView(children: <Widget>[
        for (var asset in assets.values) ...[
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
                      if (asset.main != null) SelectionOption.Main,
                      if (asset.admin != null) SelectionOption.Admin,
                      if (asset.restricted != null) SelectionOption.Restricted,
                      if (asset.qualifier != null) SelectionOption.Qualifier,
                    ],
                    behaviors: [
                      if (asset.main != null)
                        () => navigate(asset.symbol, wallet: wallet),
                      if (asset.admin != null)
                        () => navigate(asset.admin!.security.symbol,
                            wallet: wallet),
                      if (asset.restricted != null)
                        () => navigate(asset.restricted!.security.symbol,
                            wallet: wallet),
                      if (asset.qualifier != null)
                        () => navigate(asset.qualifier!.security.symbol,
                            wallet: wallet),
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
                        (asset.main != null ? 'Main ' : '') +
                            (asset.admin != null ? 'Admin ' : '') +
                            (asset.restricted != null ? 'Restricted ' : '') +
                            (asset.restricted != null ? 'Qualifier ' : ''),
                        style: Theme.of(context).holdingValue),
                  ]),
              trailing: Icon(Icons.chevron_right_rounded)),
          Divider(height: 1)
        ]
      ]);
}

class AssetHolding {
  final String symbol;
  final Balance? main;
  final Balance? admin;
  final Balance? restricted;
  final Balance? qualifier;
  final Balance? unique;
  final Balance? channel;
  final Balance? crypto;
  final Balance? fiat;

  AssetHolding({
    required this.symbol,
    this.main,
    this.admin,
    this.restricted,
    this.qualifier,
    this.unique,
    this.channel,
    this.crypto,
    this.fiat,
  });

  factory AssetHolding.fromAssetHolding(
    AssetHolding existing, {
    String? symbol,
    Balance? main,
    Balance? admin,
    Balance? restricted,
    Balance? qualifier,
    Balance? unique,
    Balance? channel,
    Balance? crypto,
    Balance? fiat,
  }) =>
      AssetHolding(
        symbol: symbol ?? existing.symbol,
        main: main ?? existing.main,
        admin: admin ?? existing.admin,
        restricted: restricted ?? existing.restricted,
        qualifier: qualifier ?? existing.qualifier,
        unique: unique ?? existing.unique,
        channel: channel ?? existing.channel,
        crypto: crypto ?? existing.crypto,
        fiat: fiat ?? existing.fiat,
      );

  @override
  String toString() => 'AssetHolding('
      'symbol: $symbol, '
      'main: $main, '
      'admin: $admin, '
      'restricted: $restricted, '
      'qualifier: $qualifier, '
      'unique: $unique, '
      'channel: $channel, '
      'crypto: $crypto, '
      'fiat: $fiat, '
      ')';

  String get typesView =>
      (main != null ? 'Main ' : '') +
      (admin != null ? 'Admin ' : '') +
      (restricted != null ? 'Restricted ' : '') +
      (qualifier != null ? 'Qualifier ' : '') +
      (unique != null ? 'Unique ' : '') +
      (channel != null ? 'Channel ' : '') +
      (crypto != null ? 'Crypto ' : '') +
      (fiat != null ? 'Fiat ' : '');

  int get length => [
        main,
        admin,
        restricted,
        qualifier,
        unique,
        channel,
        crypto,
        fiat,
      ].where((element) => element != null).length;

  String? get singleSymbol => length > 1
      ? null
      : (mainSymbol ??
          adminSymbol ??
          restrictedSymbol ??
          qualifierSymbol ??
          uniqueSymbol ??
          channelSymbol ??
          cryptoSymbol ??
          fiatSymbol ??
          null);

  String? get mainSymbol => main != null ? symbol : null;
  String? get subSymbol =>
      main != null ? '/${symbol}' : null; // sub mains allowed
  String? get adminSymbol => admin != null ? '${symbol}!' : null; // must be top
  String? get restrictedSymbol =>
      restricted != null ? '\$${symbol}' : null; // must be top
  String? get qualifierSymbol =>
      qualifier != null ? '#${symbol}' : null; // sub qualifiers allowed
  String? get uniqueSymbol =>
      unique != null ? '#${symbol}' : null; // must be subasset
  String? get channelSymbol =>
      channel != null ? '~${symbol}' : null; // must be subasset
  String? get cryptoSymbol => crypto != null
      ? (crypto?.security.symbol ?? symbol)
      : null; // not a raven asset
  String? get fiatSymbol => fiat != null
      ? (fiat?.security.symbol ?? symbol)
      : null; // not a raven asset

  // returns the best value (main, qualifier, restricted, admin, channel, unique, crypto, fiat)
  Balance? get balance =>
      main ??
      qualifier ??
      restricted ??
      admin ??
      unique ??
      channel ??
      crypto ??
      fiat ??
      null;
}
