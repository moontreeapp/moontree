part of 'cache.dart';

// primary key

class _IdKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.id;
}

extension ByKeyMethodsForCachedServerObject
    on Index<_IdKey, CachedServerObject> {
  List<CachedServerObject> getAll(String type) =>
      getByKeyStr(CachedServerObject.key(type));
}

// byHolding
class _HoldingKey extends Key<CachedServerObject> {
  @override
  String getKey(CachedServerObject cache) => cache.typeWalletChainNetId;
}

extension ByHoldingKeyMethodsForCachedServerObject
    on Index<_HoldingKey, CachedServerObject> {
  List<CachedServerObject> getAll(
          String type, String walletId, Chain chain, Net net) =>
      getByKeyStr(CachedServerObject.typeWalletChainNetKey(
        type,
        walletId,
        chain,
        net,
      ));
}
