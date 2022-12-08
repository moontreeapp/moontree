import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class AssetList extends StatefulWidget {
  const AssetList({Key? key, this.scrollController}) : super(key: key);
  final ScrollController? scrollController;

  @override
  State<AssetList> createState() => _AssetList();
}

class _AssetList extends State<AssetList> {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  late Iterable<AssetHolding> assets;
  bool showPath = false;
  int assetCount = 0;

  @override
  void initState() {
    super.initState();
    assetCount = pros.assets.length;
    listeners.add(pros.assets.changes.listen((Change<Asset> change) {
      // if vouts in our account has changed...
      final int count = pros.assets.length;
      if (count != assetCount) {
        setState(() {
          assetCount = count;
        });
      }
    }));
    listeners.add(
        pros.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where((Change<Vout> change) =>
              change.record.address?.wallet?.id == Current.walletId)
          .isNotEmpty) {
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  void _togglePath() {
    setState(() {
      showPath = !showPath;
    });
  }

  Future<void> refresh() async {
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
    assets =
        filterToAdminAssets(utils.assetHoldings(Current.holdings)).toList();
    return assets.isEmpty && pros.vouts.records.isEmpty // <-- on front tab...
        ? ComingSoonPlaceholder(
            scrollController: widget.scrollController,
            header: 'Nothing to Manage',
            message:
                'You have no admin assets.\nYou can create one by tapping Create button below.',
            placeholderType: PlaceholderType.asset)
        //? components.empty.getAssetsPlaceholder(context,
        //    scrollController: widget.scrollController, count: assetCount)
        //Container(
        //  alignment: Alignment.center,
        //  child: Scroller(
        //      controller: widget.scrollController,
        //      child: Text(
        //          'This is where assets you can manage will show up...')),
        //) //components.empty.assets(context)
        : assets.isEmpty
            ? ComingSoonPlaceholder(
                scrollController: widget.scrollController,
                header: 'Nothing to Manage',
                message:
                    'You have no admin assets.\nYou can create one by tapping Create button below.',
                placeholderType: PlaceholderType.asset)
            //? components.empty.getAssetsPlaceholder(context,
            //    scrollController: widget.scrollController, count: assetCount)
            //? Container(
            //    alignment: Alignment.center,
            //    child: Scroller(
            //        controller: widget.scrollController!,
            //        child:
            //            Text('No Assets to manage. You could create one...')),
            //  ) components.empty.assets(context)
            : Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: _assetsView(context),
              );
  }

  void navigate(String symbol, {Wallet? wallet}) {
    streams.app.manage.asset.add(symbol);
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/manage/asset',
      arguments: <String, String?>{'symbol': symbol, 'walletId': wallet?.id},
    );
  }

  ListView _assetsView(BuildContext context, {Wallet? wallet}) => ListView(
      controller: widget.scrollController,
      children: <Widget>[
            for (final AssetHolding asset in assets) ...<Widget>[
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
              const Divider(height: 1)
            ]
          ] +
          <Widget>[components.empty.blankNavArea(context)]);

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
      final Map<String, Asset?> assetDetails = <String, Asset?>{};
      if (asset.admin != null) {
        assetDetails['main'] = pros.assets.primaryIndex
            .getOne(asset.symbol, pros.settings.chain, pros.settings.net);
      }
      if (asset.subAdmin != null) {
        assetDetails['main'] = pros.assets.primaryIndex
            .getOne(asset.symbol, pros.settings.chain, pros.settings.net);
      }
      if (asset.restricted != null) {
        assetDetails['restricted'] = pros.assets.primaryIndex.getOne(
            asset.restrictedSymbol!, pros.settings.chain, pros.settings.net);
      }
      if (asset.qualifier != null) {
        assetDetails['qualifier'] = pros.assets.primaryIndex.getOne(
            asset.qualifierSymbol!, pros.settings.chain, pros.settings.net);
      }
      SelectionItems(
        context,
        symbol: asset.symbol,
        names: <SelectionOption>[
          if (asset.admin != null) SelectionOption.Main,
          if (asset.subAdmin != null) SelectionOption.Main,
          if (asset.restricted != null) SelectionOption.Restricted,
          if (asset.qualifier != null) SelectionOption.Qualifier,
        ],
        behaviors: <void Function()>[
          if (asset.admin != null) () => navigate(asset.symbol, wallet: wallet),
          if (asset.subAdmin != null)
            () => navigate(asset.symbol, wallet: wallet),
          if (asset.restricted != null)
            () => navigate(asset.restricted!.security.symbol, wallet: wallet),
          if (asset.qualifier != null)
            () => navigate(asset.qualifier!.security.symbol, wallet: wallet),
        ],
        values: <String>[
          if (asset.admin != null)
            assetDetails['main']!.amount.toSatsCommaString(),
          if (asset.subAdmin != null)
            assetDetails['main']!.amount.toSatsCommaString(),
          if (asset.restricted != null)
            assetDetails['restricted']!.amount.toSatsCommaString(),
          if (asset.qualifier != null)
            assetDetails['qualifier']!.amount.toSatsCommaString(),
        ],
      ).build();
    }
  }

  Widget leadingIcon(AssetHolding asset) => SizedBox(
      height: 40,
      width: 40,
      child: components.icons.assetAvatar(asset.restricted != null
          ? asset.restrictedSymbol!
          : asset.qualifier != null
              ? asset.qualifierSymbol!
              : asset.symbol));

  Widget title(AssetHolding asset) => Row(children: <Widget>[
        SizedBox(
            width: MediaQuery.of(context).size.width - (16 + 40 + 16 + 16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                  asset.symbol == pros.securities.RVN.symbol
                      ? 'Ravencoin'
                      : asset.symbol == pros.securities.EVR.symbol
                          ? 'Evrmore'
                          : asset.last,
                  style: Theme.of(context).textTheme.bodyText1),
            ))
        /* //this feature can show the path 
        if (asset.symbol != asset.last && showPath)
          asset.last.length >= 20
              ? Text('  (...)', style: Theme.of(context).textTheme.caption)
              : Text('   (' + asset.notLast + ')',
                  style: Theme.of(context).textTheme.caption),
                  */
      ]);
}
