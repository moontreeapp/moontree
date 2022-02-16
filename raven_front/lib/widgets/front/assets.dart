import 'dart:async';

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

  Map<String, AssetHolding> filterToAdminAssets(
    Map<String, AssetHolding> assets,
  ) {
    assets.removeWhere((key, balance) => balance.admin == null);
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    assets = filterToAdminAssets(utils.assetHoldings(Current.holdings));
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
                if (asset.length == 1 && asset.admin != null) {
                  navigate(asset.symbol, wallet: wallet);
                } else if (asset.length == 2 &&
                    asset.admin != null &&
                    asset.main != null) {
                  navigate(asset.symbol, wallet: wallet);
                } else if (asset.length == 1) {
                  navigate(asset.singleSymbol!, wallet: wallet);
                } else {
                  SelectionItems(
                    context,
                    names: [
                      if (asset.admin != null) SelectionOption.Main,
                      if (asset.restricted != null) SelectionOption.Restricted,
                      if (asset.qualifier != null) SelectionOption.Qualifier,
                    ],
                    behaviors: [
                      if (asset.main != null)
                        () => navigate(asset.symbol, wallet: wallet),
                      //if (asset.admin != null)
                      //  () => navigate(asset.admin!.security.symbol,
                      //      wallet: wallet),
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
                        [
                          if (asset.main != null) 'Main',
                          if (asset.restricted != null) 'Restricted',
                          if (asset.qualifier != null) 'Qualifier',
                        ].join(', '),
                        style: Theme.of(context).holdingValue),
                  ]),
              trailing: Icon(Icons.chevron_right_rounded)),
          Divider(height: 1)
        ]
      ]);
}
