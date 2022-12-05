part of 'address.dart';

// primary key

class _IdKey extends Key<Address> {
  @override
  String getKey(Address address) => address.id;
}

extension ByIdMethodsForAddress on Index<_IdKey, Address> {
  Address? getOne(String scripthash, Chain chain, Net net) =>
      getByKeyStr(Address.key(scripthash, chain, net)).firstOrNull;
}

// byAddress

class _AddressKey extends Key<Address> {
  @override
  String getKey(Address address) => address.address;
}

extension ByAddressMethodsForAddress on Index<_AddressKey, Address> {
  Address? getOne(String address) => getByKeyStr(address).firstOrNull;
}

// byScripthash

class _ScripthashKey extends Key<Address> {
  @override
  String getKey(Address address) => address.scripthash;
}

extension ByScripthashMethodsForAddress on Index<_ScripthashKey, Address> {
  Address? getAll(String scripthash) => getByKeyStr(scripthash).firstOrNull;
}

// byWallet

class _WalletKey extends Key<Address> {
  @override
  String getKey(Address address) => address.walletId;
}

extension ByWalletMethodsForAddress on Index<_WalletKey, Address> {
  List<Address> getAll(String walletId) => getByKeyStr(walletId);
}

// byWalletChainNet

String _walletChainNetToKey(String walletId, Chain chain, Net net) =>
    '$walletId:${ChainNet(chain, net).key}';

class _WalletChainNetKey extends Key<Address> {
  @override
  String getKey(Address address) =>
      _walletChainNetToKey(address.walletId, address.chain, address.net);
}

extension ByWalletChainNetMethodsForAddress
    on Index<_WalletChainNetKey, Address> {
  List<Address> getAll(String walletId, Chain chain, Net net) =>
      getByKeyStr(_walletChainNetToKey(walletId, chain, net));
}

// byWalletExposureChainNetKey

String _walletExposureChainNetToKey(
        String walletId, NodeExposure exposure, Chain chain, Net net) =>
    '$walletId:$exposure:${ChainNet(chain, net).key}';

class _WalletExposureChainNetKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletExposureChainNetToKey(
      address.walletId, address.exposure, address.chain, address.net);
}

extension ByWalletExposureChainNetMethodsForAddress
    on Index<_WalletExposureChainNetKey, Address> {
  List<Address> getAll(
          String walletId, NodeExposure exposure, Chain chain, Net net) =>
      getByKeyStr(_walletExposureChainNetToKey(walletId, exposure, chain, net));
}
