part of 'address.dart';

// primary key

class _IdKey extends Key<Address> {
  @override
  String getKey(Address address) => address.id;
}

extension ByIdMethodsForAddress on Index<_IdKey, Address> {
  Address? getOne(String walletId, NodeExposure exposure, int index) =>
      getByKeyStr(Address.key(walletId, exposure, index)).firstOrNull;
}

// byScripthash

class _ScripthashKey extends Key<Address> {
  @override
  String getKey(Address address) => address.scripthash;
}

extension ByScripthashMethodsForAddress on Index<_ScripthashKey, Address> {
  Address? getOne(String scripthash) => getByKeyStr(scripthash).firstOrNull;
}

// byH160

class _H160Key extends Key<Address> {
  @override
  String getKey(Address address) => address.scripthash;
}

extension ByH160MethodsForAddress on Index<_H160Key, Address> {
  Address? getOne(String h160) => getByKeyStr(h160).firstOrNull;
}

// byWallet

class _WalletKey extends Key<Address> {
  @override
  String getKey(Address address) => address.walletId;
}

extension ByWalletMethodsForAddress on Index<_WalletKey, Address> {
  List<Address> getAll(String walletId) => getByKeyStr(walletId);
}

// byWalletExposureKey

class _WalletExposureKey extends Key<Address> {
  @override
  String getKey(Address address) => address.walletExposureId;
}

extension ByWalletExposureMethodsForAddress
    on Index<_WalletExposureKey, Address> {
  List<Address> getAll(String walletId, NodeExposure exposure) =>
      getByKeyStr(Address.walletExposureKey(walletId, exposure));
}
