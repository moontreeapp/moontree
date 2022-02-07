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

  List<AssetHolding> assetHoldingsMainOnly() {
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

  List<AssetHolding> assetHoldings() {
    var holdings = Current.holdings
        .where((Balance balance) => balance.security.isAsset)
        .map((Balance balance) => balance.security.symbol);
    var mains = [];
    var admins = [];
    var restricteds = [];
    var qualifiers = [];
    var uniques = [];
    var channels = [];
    for (var name in holdings) {
      if (name.startsWith('#')) {
        qualifiers.add(name);
      } else if (name.startsWith('\$')) {
        restricteds.add(name);
      } else if (name.endsWith('!')) {
        admins.add(name);
      } else {
        if (name.contains('/')) {
          var lastName = name.split('/').last;
          if (lastName.startsWith('#')) {
            uniques.add(name);
          } else if (name.startsWith('~')) {
            channels.add(name);
          } else {
            mains.add(name);
          }
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
    var cleanedUniques = uniques;
    var cleanedChannels = channels;
    return [
      for (var name in cleanedMains
        ..addAll(cleanedAdmins)
        ..addAll(cleanedRestricteds)
        ..addAll(cleanedQualifiers)
        ..addAll(cleanedUniques)
        ..addAll(cleanedChannels))
        if (cleanedAdmins.contains(name))
          AssetHolding(
            symbol: name,
            main: cleanedMains.contains(name),
            admin: cleanedAdmins.contains(name),
            restricted: cleanedRestricteds.contains(name),
            qualifier: cleanedQualifiers.contains(name),
            unique: cleanedUniques.contains(name),
            channel: cleanedChannels.contains(name),
          )
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
        for (var asset in assets) ...[
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
                      if (asset.admin) SelectionOption.Admin,
                      if (asset.restricted) SelectionOption.Restricted,
                      if (asset.qualifier) SelectionOption.Qualifier,
                    ],
                    behaviors: [
                      if (asset.main)
                        () => navigate(asset.symbol, wallet: wallet),
                      if (asset.admin)
                        () => navigate(asset.adminSymbol!, wallet: wallet),
                      if (asset.restricted)
                        () => navigate(asset.restrictedSymbol!, wallet: wallet),
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
              trailing: Icon(Icons.chevron_right_rounded)),
          Divider(height: 1)
        ]
      ]);
}

class AssetHolding {
  final String symbol;
  final bool main;
  final bool admin;
  final bool restricted;
  final bool qualifier;
  final bool unique;
  final bool channel;

  AssetHolding({
    required this.symbol,
    this.main = false,
    this.admin = false,
    this.restricted = false,
    this.qualifier = false,
    this.unique = false,
    this.channel = false,
  });

  @override
  String toString() => 'AssetHolding('
      'main: $main, '
      'admin: $admin, '
      'restricted: $restricted, '
      'qualifier: $qualifier, '
      'unique: $unique, '
      'channel: $channel)';

  String get typesView =>
      (main ? 'Main ' : '') +
      (admin ? 'Admin ' : '') +
      (restricted ? 'Restricted ' : '') +
      (qualifier ? 'Qualifier ' : '') +
      (unique ? 'Unique ' : '') +
      (channel ? 'Channel ' : '');

  int get length => [main, admin, restricted, qualifier, unique, channel]
      .where((element) => element)
      .length;

  String? get singleSymbol => length > 1
      ? null
      : main
          ? symbol
          : adminSymbol ??
              restrictedSymbol ??
              qualifierSymbol ??
              uniqueSymbol ??
              channelSymbol ??
              null;

  String? get subSymbol => main ? '/${symbol}' : null; // sub mains allowed
  String? get adminSymbol => admin ? '${symbol}!' : null; // must be top
  String? get restrictedSymbol =>
      restricted ? '\$${symbol}' : null; // must be top
  String? get qualifierSymbol =>
      qualifier ? '#${symbol}' : null; // sub qualifiers allowed
  String? get uniqueSymbol => unique ? '#${symbol}' : null; // must be subasset
  String? get channelSymbol =>
      channel ? '~${symbol}' : null; // must be subasset
}
