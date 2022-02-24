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
  late Map<String, AssetHolding> assets;

  @override
  void initState() {
    super.initState();
    listeners.add(
        res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where((change) =>
              change.data.address?.wallet?.walletId == Current.walletId)
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

  //Map<String, AssetHolding> assetHoldings({bool assetsOnly = false}) {
  //  /// we don't want to just see holdings here we want to see all subassets
  //  /// that we have the ability to manage (if we own the admin token).
  //  //var holdings = assetsOnly
  //  //    ? Current.holdings.where((Balance balance) => balance.security.isAsset)
  //  //    : Current.holdings;
  //  Map<String, AssetHolding> balances = {};
  //  for (var balance in holdings) {
  //    var baseSymbol =
  //        balance.security.asset?.baseSymbol ?? balance.security.symbol;
  //    var assetType =
  //        balance.security.asset?.assetType ?? balance.security.securityType;
  //    if (!balances.containsKey(baseSymbol)) {
  //      balances[baseSymbol] = AssetHolding(
  //        symbol: baseSymbol,
  //        main: assetType == AssetType.Main ? balance : null,
  //        admin: assetType == AssetType.Admin ? balance : null,
  //        restricted: assetType == AssetType.Restricted ? balance : null,
  //        qualifier: assetType == AssetType.Qualifier ? balance : null,
  //        unique: assetType == AssetType.NFT ? balance : null,
  //        channel: assetType == AssetType.Channel ? balance : null,
  //        crypto: assetType == SecurityType.Crypto ? balance : null,
  //        fiat: assetType == SecurityType.Fiat ? balance : null,
  //      );
  //    } else {
  //      balances[baseSymbol] = AssetHolding.fromAssetHolding(
  //        balances[baseSymbol]!,
  //        main: assetType == AssetType.Main ? balance : null,
  //        admin: assetType == AssetType.Admin ? balance : null,
  //        restricted: assetType == AssetType.Restricted ? balance : null,
  //        qualifier: assetType == AssetType.Qualifier ? balance : null,
  //        unique: assetType == AssetType.NFT ? balance : null,
  //        channel: assetType == AssetType.Channel ? balance : null,
  //        crypto: assetType == SecurityType.Crypto ? balance : null,
  //        fiat: assetType == SecurityType.Fiat ? balance : null,
  //      );
  //    }
  //  }
  //  return balances;
  //}

  Map<String, AssetHolding> filterToSubAssetsFor(
      String asset, Map<String, AssetHolding> assets) {
    //var prefix = '$asset/'; // filter out NFTs and message channels
    var subAssetKeys = assets.keys.where((String symbol) =>
            symbol.startsWith(asset) &&
            symbol.length > asset.length + 2 &&
            !symbol.substring(asset.length + 1, symbol.length).contains('/') &&
            !symbol.substring(asset.length + 1, symbol.length).contains('~')
        //&& (!symbol.contains('#') || symbol.contains('/#')) // filter out NFTS
        );
    assets.removeWhere((key, value) => !subAssetKeys.contains(key));
    //assets.removeWhere((key, value) => !key.startsWith(prefix));
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    //assets = filterToSubAssetsFor(widget.symbol, assetHoldings());
    assets = filterToSubAssetsFor(
        widget.symbol, utils.assetHoldingsFromAssets(widget.symbol));
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
    print('sending $symbol');
    Navigator.of(components.navigator.routeContext!).pushReplacementNamed(
      '/manage/asset',
      arguments: {'symbol': symbol, 'walletId': wallet?.walletId ?? null},
    );
  }

  ListView _assetsView(BuildContext context, {Wallet? wallet}) => ListView(
          children: <Widget>[
        for (var asset in assets.values)
          ListTile(
              //dense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              onTap: () {
                if ((asset.length == 1) ||
                    (asset.length == 2 &&
                            (asset.admin != null && asset.main != null) ||
                        (asset.admin != null && asset.unique != null) ||
                        (asset.main != null && asset.unique != null)) ||
                    (asset.length == 3 &&
                        asset.admin != null &&
                        asset.main != null &&
                        asset.unique != null)) {
                  navigate(
                    asset.symbol,
                    wallet: wallet,
                  );
                } else {
                  SelectionItems(
                    context,
                    names: [
                      if (asset.admin != null) SelectionOption.Main,
                      //if (asset.main != null) SelectionOption.Main,
                      if (asset.unique != null) SelectionOption.NFT,
                      if (asset.qualifier != null) SelectionOption.Qualifier,
                    ],
                    behaviors: [
                      if (asset.admin != null)
                        () => navigate(
                              '${widget.symbol}/${asset.subSymbol!}',
                              wallet: wallet,
                            ),
                      //if (asset.main != null)
                      //  () => navigate(
                      //        '${widget.symbol}/${asset.subSymbol!}',
                      //        wallet: wallet,
                      //      ),
                      if (asset.unique != null)
                        () => navigate(
                              '${widget.symbol}/${asset.uniqueSymbol!}',
                              wallet: wallet,
                            ),
                      if (asset.qualifier != null)
                        () => navigate(
                              '${widget.symbol}/${asset.qualifierSymbol!}',
                              wallet: wallet,
                            ),
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
                    Text(asset.last, style: Theme.of(context).holdingName),
                    Text(
                        [
                          if (asset.admin != null) 'Admin',
                          //if (asset.main != null) 'Main',
                          if (asset.channel != null) 'Channel',
                          if (asset.unique != null) 'NFT',
                          if (asset.restricted != null) 'Restricted',
                          if (asset.qualifier != null) 'Qualifier',
                        ].join(', '),
                        style: Theme.of(context).holdingValue),
                  ]),
              trailing: Icon(Icons.chevron_right_rounded))
      ].intersperse(Divider(height: 1)).toList());
}
