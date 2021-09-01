part of 'address.dart';

// primary key

class _ScripthashKey extends Key<Address> {
  @override
  String getKey(Address address) => address.scripthash;
}

extension ByRawScripthashMethodsForAddress on Index<_AccountKey, Address> {
  Address? getOne(String scripthash) => getByKeyStr(scripthash).firstOrNull;
}

// byAccount

class _AccountKey extends Key<Address> {
  @override
  String getKey(Address address) => address.accountId;
}

extension ByAccountMethodsForAddress on Index<_AccountKey, Address> {
  List<Address> getAll(String accountId) => getByKeyStr(accountId);
}

// byWallet

class _WalletKey extends Key<Address> {
  @override
  String getKey(Address address) => address.walletId;
}

extension ByWalletMethodsForAddress on Index<_WalletKey, Address> {
  List<Address> getAll(String walletId) => getByKeyStr(walletId);
}

// byWalletExposure

String _walletExposureToKey(String walletId, NodeExposure exposure) =>
    '$walletId:$exposure';

class _WalletExposureKey extends Key<Address> {
  @override
  String getKey(Address address) =>
      _walletExposureToKey(address.walletId, address.exposure);
}

extension ByWalletExposureMethodsForAddress
    on Index<_WalletExposureKey, Address> {
  List<Address> getAll(String walletId, NodeExposure exposure) =>
      getByKeyStr(_walletExposureToKey(walletId, exposure));
}
