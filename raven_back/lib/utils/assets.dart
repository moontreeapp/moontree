/// used to aggregate multiple balances into one asset tree
import 'package:raven_back/raven_back.dart';

Map<String, AssetHolding> assetHoldings(Iterable<Balance> holdings) {
  // ignore: omit_local_variable_types
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
