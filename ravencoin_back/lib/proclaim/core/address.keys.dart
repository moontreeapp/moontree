part of 'address.dart';

// primary key

class _IdKey extends Key<Address> {
  @override
  String getKey(Address address) => address.uid;
}

extension ByRawScripthashMethodsForAddress on Index<_IdKey, Address> {
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
    '$walletId:${chainNetKey(chain, net)}';

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

// byWalletExposure

String _walletExposureToKey(
        String walletId, NodeExposure exposure, Chain chain, Net net) =>
    '$walletId:$exposure:${chainNetKey(chain, net)}';

class _WalletExposureKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletExposureToKey(
      address.walletId, address.exposure, address.chain, address.net);
}

extension ByWalletExposureMethodsForAddress
    on Index<_WalletExposureKey, Address> {
  List<Address> getAll(
          String walletId, NodeExposure exposure, Chain chain, Net net) =>
      getByKeyStr(_walletExposureToKey(walletId, exposure, chain, net));
}

// byWalletExposureIndex

String _walletExposureHDToKey(String walletId, NodeExposure exposure,
        int hdIndex, Chain chain, Net net) =>
    '$walletId:$exposure:$hdIndex:${chainNetKey(chain, net)}';

class _WalletExposureHDKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletExposureHDToKey(address.walletId,
      address.exposure, address.hdIndex, address.chain, address.net);
}

extension ByWalletExposureHDMethodsForAddress
    on Index<_WalletExposureHDKey, Address> {
  Address? getOne(String walletId, NodeExposure exposure, int hdIndex,
          Chain chain, Net net) =>
      getByKeyStr(
              _walletExposureHDToKey(walletId, exposure, hdIndex, chain, net))
          .firstOrNull;
}
