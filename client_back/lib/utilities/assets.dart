/// used to aggregate multiple balances into one asset tree
// ignore_for_file: omit_local_variable_types

import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';

// unused. see https://github.com/moontreeapp/moontreeV1/issues/648
Set<Security> securityFromTransactions(Iterable<Transaction> transactions) =>
    <List<Security>>[
      for (Transaction transaction in transactions)
        <Security>[for (Vin vin in transaction.vins) vin.security!] +
            <Security>[for (Vout vout in transaction.vouts) vout.security!]
    ].expand((List<Security> e) => e).toSet();

/*
List<AssetHolding> assetHoldingsFromBalances(Iterable<Balance> holdings) {
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
    final Enum symbolType =
        balance.security.asset?.symbolType ?? balance.security.getSecurityType;
    if (<SymbolType>[SymbolType.main, SymbolType.admin].contains(symbolType)) {
      if (!balancesMain.containsKey(baseSymbol)) {
        balancesMain[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          main: symbolType == SymbolType.main ? balance : null,
          admin: symbolType == SymbolType.admin ? balance : null,
        );
      } else {
        balancesMain[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesMain[baseSymbol]!,
          main: symbolType == SymbolType.main ? balance : null,
          admin: symbolType == SymbolType.admin ? balance : null,
        );
      }
    } else if (<SymbolType>[SymbolType.sub, SymbolType.subAdmin]
        .contains(symbolType)) {
      if (!balancesSub.containsKey(baseSymbol)) {
        balancesSub[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          sub: symbolType == SymbolType.sub ? balance : null,
          subAdmin: symbolType == SymbolType.subAdmin ? balance : null,
        );
      } else {
        balancesSub[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesSub[baseSymbol]!,
          sub: symbolType == SymbolType.sub ? balance : null,
          subAdmin: symbolType == SymbolType.subAdmin ? balance : null,
        );
      }
    } else {
      if (!balancesOther.containsKey(baseSymbol)) {
        balancesOther[baseSymbol] = AssetHolding(
          symbol: baseSymbol,
          nft: symbolType == SymbolType.unique ? balance : null,
          channel: symbolType == SymbolType.channel ? balance : null,
          restricted: symbolType == SymbolType.restricted ? balance : null,
          qualifier: symbolType == SymbolType.qualifier ? balance : null,
          qualifierSub: symbolType == SymbolType.qualifierSub ? balance : null,
          coin: symbolType == SecurityType.coin ? balance : null,
          fiat: symbolType == SecurityType.fiat ? balance : null,
        );
      } else {
        balancesOther[baseSymbol] = AssetHolding.fromAssetHolding(
          balancesOther[baseSymbol]!,
          nft: symbolType == SymbolType.unique ? balance : null,
          channel: symbolType == SymbolType.channel ? balance : null,
          restricted: symbolType == SymbolType.restricted ? balance : null,
          qualifier: symbolType == SymbolType.qualifier ? balance : null,
          qualifierSub: symbolType == SymbolType.qualifierSub ? balance : null,
          coin: symbolType == SecurityType.coin ? balance : null,
          fiat: symbolType == SecurityType.fiat ? balance : null,
        );
      }
    }
  }
  return balancesMain.values.toList() +
      balancesSub.values.toList() +
      balancesOther.values.toList();
}*/
List<AssetHolding> assetHoldings(Iterable<BalanceView> holdings) {
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
  for (final BalanceView balance in holdings) {
    final symbol =
        Symbol(balance.symbol)(ChainExtension.from(balance.chain!), Net.main);
    if (<SymbolType>[SymbolType.main, SymbolType.admin]
        .contains(symbol.symbolType)) {
      if (!balancesMain.containsKey(symbol.baseSymbol)) {
        balancesMain[symbol.baseSymbol] = AssetHolding(
          symbol: symbol.baseSymbol,
          main: symbol.symbolType == SymbolType.main ? balance : null,
          admin: symbol.symbolType == SymbolType.admin ? balance : null,
        );
      } else {
        balancesMain[symbol.baseSymbol] = AssetHolding.fromAssetHolding(
          balancesMain[symbol.baseSymbol]!,
          main: symbol.symbolType == SymbolType.main ? balance : null,
          admin: symbol.symbolType == SymbolType.admin ? balance : null,
        );
      }
    } else if (<SymbolType>[SymbolType.sub, SymbolType.subAdmin]
        .contains(symbol.symbolType)) {
      if (!balancesSub.containsKey(symbol.baseSymbol)) {
        balancesSub[symbol.baseSymbol] = AssetHolding(
          symbol: symbol.baseSymbol,
          sub: symbol.symbolType == SymbolType.sub ? balance : null,
          subAdmin: symbol.symbolType == SymbolType.subAdmin ? balance : null,
        );
      } else {
        balancesSub[symbol.baseSymbol] = AssetHolding.fromAssetHolding(
          balancesSub[symbol.baseSymbol]!,
          sub: symbol.symbolType == SymbolType.sub ? balance : null,
          subAdmin: symbol.symbolType == SymbolType.subAdmin ? balance : null,
        );
      }
    } else {
      if (!balancesOther.containsKey(symbol.baseSymbol)) {
        balancesOther[symbol.baseSymbol] = AssetHolding(
          symbol: symbol.baseSymbol,
          nft: symbol.symbolType == SymbolType.unique ? balance : null,
          channel: symbol.symbolType == SymbolType.channel ? balance : null,
          restricted:
              symbol.symbolType == SymbolType.restricted ? balance : null,
          qualifier: symbol.symbolType == SymbolType.qualifier ? balance : null,
          qualifierSub:
              symbol.symbolType == SymbolType.qualifierSub ? balance : null,
          coin: symbol.symbolType == SecurityType.coin ? balance : null,
          fiat: symbol.symbolType == SecurityType.fiat ? balance : null,
        );
      } else {
        balancesOther[symbol.baseSymbol] = AssetHolding.fromAssetHolding(
          balancesOther[symbol.baseSymbol]!,
          nft: symbol.symbolType == SymbolType.unique ? balance : null,
          channel: symbol.symbolType == SymbolType.channel ? balance : null,
          restricted:
              symbol.symbolType == SymbolType.restricted ? balance : null,
          qualifier: symbol.symbolType == SymbolType.qualifier ? balance : null,
          qualifierSub:
              symbol.symbolType == SymbolType.qualifierSub ? balance : null,
          coin: symbol.symbolType == SecurityType.coin ? balance : null,
          fiat: symbol.symbolType == SecurityType.fiat ? balance : null,
        );
      }
    }
  }
  return balancesMain.values.toList() +
      balancesSub.values.toList() +
      balancesOther.values.toList();
}

BalanceView blank(Asset asset) =>
    BalanceView(sats: 0, symbol: '', chain: 'none');

Map<String, AssetHolding> assetHoldingsFromAssets(String parent) {
  final Map<String, AssetHolding> assets = <String, AssetHolding>{};
  for (final Asset asset in pros.assets) {
    final SymbolType symbolType = asset.symbolType;
    if (!assets.containsKey(asset.baseSubSymbol)) {
      assets[asset.baseSubSymbol] = AssetHolding(
        symbol: asset.baseSubSymbol,
        main: symbolType == SymbolType.main ? blank(asset) : null,
        admin: symbolType == SymbolType.admin ? blank(asset) : null,
        restricted: symbolType == SymbolType.restricted ? blank(asset) : null,
        qualifier: symbolType == SymbolType.qualifier ? blank(asset) : null,
        nft: symbolType == SymbolType.unique ? blank(asset) : null,
        channel: symbolType == SymbolType.channel ? blank(asset) : null,
        //crypto: symbolType == SecurityType.crypto ? blank(asset) : null,
        //fiat: symbolType == SecurityType.fiat ? blank(asset) : null,
      );
    } else {
      assets[asset.baseSubSymbol] = AssetHolding.fromAssetHolding(
        assets[asset.baseSubSymbol]!,
        main: symbolType == SymbolType.main ? blank(asset) : null,
        admin: symbolType == SymbolType.admin ? blank(asset) : null,
        restricted: symbolType == SymbolType.restricted ? blank(asset) : null,
        qualifier: symbolType == SymbolType.qualifier ? blank(asset) : null,
        nft: symbolType == SymbolType.unique ? blank(asset) : null,
        channel: symbolType == SymbolType.channel ? blank(asset) : null,
        //crypto: symbolType == SecurityType.crypto ? blank(asset) : null,
        //fiat: symbolType == SecurityType.fiat ? blank(asset) : null,
      );
    }
  }
  return assets;
}
