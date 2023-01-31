part of 'cache.dart';

/// primary key

class _IdKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.id;
}

extension ByKeyMethodsForCachedServerObject
    on Index<_IdKey, CachedServerObject> {
  List<CachedServerObject> getAll(String type) =>
      getByKeyStr(CachedServerObject.key(type));
}

/// byHolding

class _HoldingKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.typeWalletChainNetId;
}

extension ByHoldingKeyMethodsForCachedServerObject
    on Index<_HoldingKey, CachedServerObject> {
  List<CachedServerObject> getAll(
    String walletId,
    Chain chain,
    Net net, {
    String? type,
  }) =>
      getByKeyStr(CachedServerObject.typeWalletChainNetKey(
        type ?? 'BalanceView',
        walletId,
        chain,
        net,
      ));
}

/// byAsset

class _AssetMetadataKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.typeSymbolChainNetId;
}

extension ByAssetMetadataKeyMethodsForCachedServerObject
    on Index<_AssetMetadataKey, CachedServerObject> {
  List<CachedServerObject> getAll(
    String symbol,
    Chain chain,
    Net net, {
    String? type,
  }) =>
      getByKeyStr(CachedServerObject.typeSymbolChainNetKey(
        type ?? 'AssetMetadata',
        symbol,
        chain,
        net,
      ));
}

/// byTransactionDetail

class _TransactionDetailKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.typeHashWalletChainNetId;
}

extension ByTransactionDetailKeyMethodsForCachedServerObject
    on Index<_TransactionDetailKey, CachedServerObject> {
  CachedServerObject? getOne(
    String walletId,
    String txHash,
    Chain chain,
    Net net, {
    String? type,
  }) =>
      getByKeyStr(CachedServerObject.typeHashWalletChainNetKey(
        type ?? 'TransactionDetailsView',
        txHash,
        walletId,
        chain,
        net,
      )).firstOrNull;
}

/// byTransactionsByHeight

class _TransactionsByHeightKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) =>
      cache.typeHeightSymbolWalletChainNetId;
}

extension ByTransactionsByHeightKeyMethodsForCachedServerObject
    on Index<_TransactionsByHeightKey, CachedServerObject> {
  List<CachedServerObject> getAll(
    int height,
    String symbol,
    String walletId,
    Chain chain,
    Net net, {
    String? type,
  }) =>
      getByKeyStr(CachedServerObject.typeHeightSymbolWalletChainNetKey(
        type ?? 'TransactionView',
        height,
        symbol,
        walletId,
        chain,
        net,
      ));
}

/// byTransactionDetail

class _TransactionsKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.typeSymbolWalletChainNetId;
}

extension ByTransactionsKeyMethodsForCachedServerObject
    on Index<_TransactionsKey, CachedServerObject> {
  List<CachedServerObject> getAll(
    String symbol,
    String walletId,
    Chain chain,
    Net net, {
    String? type,
  }) =>
      getByKeyStr(CachedServerObject.typeSymbolWalletChainNetKey(
        type ?? 'TransactionView',
        symbol,
        walletId,
        chain,
        net,
      ));
}
