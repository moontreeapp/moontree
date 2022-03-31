import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/widgets/widgets.dart';

class AssetList extends StatefulWidget {
  final ScrollController scrollController;
  const AssetList({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<AssetList> createState() => _AssetList();
}

class _AssetList extends State<AssetList> {
  List<StreamSubscription> listeners = [];
  late Iterable<AssetHolding> assets;
  bool showPath = false;

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
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  void _togglePath() {
    setState(() {
      showPath = !showPath;
    });
  }

  Future refresh() async {
    await services.history.produceAddressOrBalance();
    setState(() {});
  }

  Iterable<AssetHolding> filterToAdminAssets(List<AssetHolding> assets) =>
      assets.where((AssetHolding asset) =>
          asset.admin != null ||
          asset.subAdmin != null ||
          asset.channel != null ||
          asset.qualifier != null ||
          asset.qualifierSub != null ||
          asset.restricted != null);

  @override
  Widget build(BuildContext context) {
    assets = filterToAdminAssets(utils.assetHoldings(Current.holdings));
    return assets.isEmpty && res.vouts.data.isEmpty // <-- on front tab...
        ? Container(
            alignment: Alignment.center,
            child: Scroller(
                controller: widget.scrollController,
                child: Text(
                    'This is where assets you can manage will show up...')),
          ) //components.empty.assets(context)
        : assets.isEmpty
            ? Container(
                alignment: Alignment.center,
                child: Scroller(
                    controller: widget.scrollController,
                    child:
                        Text('No Assets to manage. You could create one...')),
              ) //components.empty.assets(context)
            : Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 8.0),
                child: _assetsView(context),
              );
  }

  void navigate(String symbol, {Wallet? wallet}) {
    streams.app.manage.asset.add(symbol);
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/manage/asset',
      arguments: {'symbol': symbol, 'walletId': wallet?.id ?? null},
    );
  }

  ListView _assetsView(BuildContext context, {Wallet? wallet}) =>
      ListView(controller: widget.scrollController, children: <Widget>[
        for (var asset in assets) ...[
          ListTile(
            //dense: true,
            //contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            // wallet transactions are on wallet screen, so remove wallet id here.
            onTap: () => onTap(wallet, asset),
            onLongPress: _togglePath,
            leading: leadingIcon(asset),
            title: title(asset),
            //trailing: Icon(Icons.chevron_right_rounded)
          ),
          Divider(height: 1)
        ]
      ]);

  void onTap(Wallet? wallet, AssetHolding asset) {
    if (asset.length == 1 && (asset.admin != null || asset.subAdmin != null)) {
      navigate(asset.symbol, wallet: wallet);
    } else if (asset.length == 2 && asset.admin != null && asset.main != null) {
      navigate(asset.symbol, wallet: wallet);
    } else if (asset.length == 2 &&
        asset.subAdmin != null &&
        asset.sub != null) {
      navigate(asset.symbol, wallet: wallet);
    } else if (asset.length == 2 &&
        asset.subAdmin != null &&
        asset.nft != null) {
      navigate(asset.symbol, wallet: wallet);
    } else if (asset.length == 1) {
      navigate(asset.singleSymbol!, wallet: wallet);
    } else {
      var assetDetails = {};
      if (asset.admin != null) {
        assetDetails['main'] = res.assets.primaryIndex.getOne(asset.symbol);
      }
      if (asset.subAdmin != null) {
        assetDetails['main'] = res.assets.primaryIndex.getOne(asset.symbol);
      }
      if (asset.restricted != null) {
        assetDetails['restricted'] =
            res.assets.primaryIndex.getOne(asset.restrictedSymbol!);
      }
      if (asset.qualifier != null) {
        assetDetails['qualifier'] =
            res.assets.primaryIndex.getOne(asset.qualifierSymbol!);
      }
      SelectionItems(
        context,
        symbol: asset.symbol,
        names: [
          if (asset.admin != null) SelectionOption.Main,
          if (asset.subAdmin != null) SelectionOption.Main,
          if (asset.restricted != null) SelectionOption.Restricted,
          if (asset.qualifier != null) SelectionOption.Qualifier,
        ],
        behaviors: [
          if (asset.admin != null) () => navigate(asset.symbol, wallet: wallet),
          if (asset.subAdmin != null)
            () => navigate(asset.symbol, wallet: wallet),
          if (asset.restricted != null)
            () => navigate(asset.restricted!.security.symbol, wallet: wallet),
          if (asset.qualifier != null)
            () => navigate(asset.qualifier!.security.symbol, wallet: wallet),
        ],
        values: [
          if (asset.admin != null)
            utils
                .satToAmount(assetDetails['main'].satsInCirculation)
                .toCommaString(),
          if (asset.subAdmin != null)
            utils
                .satToAmount(assetDetails['main'].satsInCirculation)
                .toCommaString(),
          if (asset.restricted != null)
            utils
                .satToAmount(assetDetails['restricted'].satsInCirculation)
                .toCommaString(),
          if (asset.qualifier != null)
            utils
                .satToAmount(assetDetails['qualifier'].satsInCirculation)
                .toCommaString(),
        ],
      ).build();
    }
  }

  Widget leadingIcon(AssetHolding asset) => Container(
      height: 40,
      width: 40,
      child: components.icons.assetAvatar(asset.restricted != null
          ? asset.restrictedSymbol!
          : asset.qualifier != null
              ? asset.qualifierSymbol!
              : asset.symbol));

  Widget title(AssetHolding asset) =>
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(asset.symbol == 'RVN' ? 'Ravencoin' : asset.last,
            style: Theme.of(context).textTheme.bodyText1),
        /* //this feature can show the path 
        if (asset.symbol != asset.last && showPath)
          asset.last.length >= 20
              ? Text('  (...)', style: Theme.of(context).textTheme.caption)
              : Text('   (' + asset.notLast + ')',
                  style: Theme.of(context).textTheme.caption),
                  */
      ]);
}
