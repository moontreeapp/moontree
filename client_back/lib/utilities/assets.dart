/// used to aggregate multiple balances into one asset tree
// ignore_for_file: omit_local_variable_types

import 'package:client_back/client_back.dart';

// unused. see https://github.com/moontreeapp/moontreeV1/issues/648
Set<Security> securityFromTransactions(Iterable<Transaction> transactions) =>
    <List<Security>>[
      for (Transaction transaction in transactions)
        <Security>[for (Vin vin in transaction.vins) vin.security!] +
            <Security>[for (Vout vout in transaction.vouts) vout.security!]
    ].expand((List<Security> e) => e).toSet();

List<AssetHolding> assetHoldings(Iterable<Balance> holdings) {
  final Map<String, AssetHolding> balancesMain = <String, AssetHolding>{};
  final Map<String, AssetHolding> balancesSub = <String, AssetHolding>{};
  final Map<String, AssetHolding> balancesOther = <String, AssetHolding>{};
  //if (holdings.isEmpty) {
  //  holdings = [
  //    Balance(
  //        confirmed: 0,
  //        unconfirmed: 0,
  //        security: pros.securities.currentCoin,
  //        walletId: pros.settings.currentWalletId)
  //  ];
  //}
  for (final Balance balance in holdings) {
    final String baseSymbol =
        balance.security.asset?.baseSymbol ?? balance.security.symbol;
    final Enum assetType =
        balance.security.asset?.assetType ?? balance.security.getSecurityType;
    if (<AssetType>[AssetType.main, AssetType.admin].contains(assetType)) {
      if (!balancesMain.containsKey(baseSymbol)) {
        balancesMain[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          main: assetType == AssetType.main ? balance : null,
          admin: assetType == AssetType.admin ? balance : null,
        );
      } else {
        balancesMain[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesMain[baseSymbol]!,
          main: assetType == AssetType.main ? balance : null,
          admin: assetType == AssetType.admin ? balance : null,
        );
      }
    } else if (<AssetType>[AssetType.sub, AssetType.subAdmin]
        .contains(assetType)) {
      if (!balancesSub.containsKey(baseSymbol)) {
        balancesSub[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          sub: assetType == AssetType.sub ? balance : null,
          subAdmin: assetType == AssetType.subAdmin ? balance : null,
        );
      } else {
        balancesSub[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesSub[baseSymbol]!,
          sub: assetType == AssetType.sub ? balance : null,
          subAdmin: assetType == AssetType.subAdmin ? balance : null,
        );
      }
    } else {
      if (!balancesOther.containsKey(baseSymbol)) {
        balancesOther[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          nft: assetType == AssetType.unique ? balance : null,
          channel: assetType == AssetType.channel ? balance : null,
          restricted: assetType == AssetType.restricted ? balance : null,
          qualifier: assetType == AssetType.qualifier ? balance : null,
          qualifierSub: assetType == AssetType.qualifierSub ? balance : null,
          coin: assetType == SecurityType.coin ? balance : null,
          fiat: assetType == SecurityType.fiat ? balance : null,
        );
      } else {
        balancesOther[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesOther[baseSymbol]!,
          nft: assetType == AssetType.unique ? balance : null,
          channel: assetType == AssetType.channel ? balance : null,
          restricted: assetType == AssetType.restricted ? balance : null,
          qualifier: assetType == AssetType.qualifier ? balance : null,
          qualifierSub: assetType == AssetType.qualifierSub ? balance : null,
          coin: assetType == SecurityType.coin ? balance : null,
          fiat: assetType == SecurityType.fiat ? balance : null,
        );
      }
    }
  }
  return balancesMain.values.toList() +
      balancesSub.values.toList() +
      balancesOther.values.toList();
}

Balance blank(Asset asset) => Balance(
    walletId: '',
    confirmed: 0,
    unconfirmed: 0,
    security: asset.security ??
        Security(symbol: asset.symbol, chain: Chain.none, net: Net.test));

Map<String, AssetHolding> assetHoldingsFromAssets(String parent) {
  final Map<String, AssetHolding> assets = <String, AssetHolding>{};
  for (final Asset asset in pros.assets) {
    final AssetType assetType = asset.assetType;
    if (!assets.containsKey(asset.baseSubSymbol)) {
      assets[asset.baseSubSymbol] = AssetHolding(
        symbol: asset.baseSubSymbol,
        main: assetType == AssetType.main ? blank(asset) : null,
        admin: assetType == AssetType.admin ? blank(asset) : null,
        restricted: assetType == AssetType.restricted ? blank(asset) : null,
        qualifier: assetType == AssetType.qualifier ? blank(asset) : null,
        nft: assetType == AssetType.unique ? blank(asset) : null,
        channel: assetType == AssetType.channel ? blank(asset) : null,
        //crypto: assetType == SecurityType.crypto ? blank(asset) : null,
        //fiat: assetType == SecurityType.fiat ? blank(asset) : null,
      );
    } else {
      assets[asset.baseSubSymbol] = AssetHolding.fromAssetHolding(
        assets[asset.baseSubSymbol]!,
        main: assetType == AssetType.main ? blank(asset) : null,
        admin: assetType == AssetType.admin ? blank(asset) : null,
        restricted: assetType == AssetType.restricted ? blank(asset) : null,
        qualifier: assetType == AssetType.qualifier ? blank(asset) : null,
        nft: assetType == AssetType.unique ? blank(asset) : null,
        channel: assetType == AssetType.channel ? blank(asset) : null,
        //crypto: assetType == SecurityType.crypto ? blank(asset) : null,
        //fiat: assetType == SecurityType.fiat ? blank(asset) : null,
      );
    }
  }
  return assets;
}
