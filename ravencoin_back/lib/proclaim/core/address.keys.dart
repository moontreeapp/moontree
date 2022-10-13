part of 'address.dart';

// primary key

class _IdKey extends Key<Address> {
  @override
  String getKey(Address address) => address.idKey;
}

extension ByIdMethodsForAddress on Index<_IdKey, Address> {
  Address? getOne(String addressId) => getByKeyStr(addressId).firstOrNull;
}

// byAddress

class _AddressKey extends Key<Address> {
  @override
  String getKey(Address address) => address.address;
}

extension ByAddressMethodsForAddress on Index<_AddressKey, Address> {
  Address? getOne(String? address) =>
      address == null ? null : getByKeyStr(address).firstOrNull;
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

// byWalletExposureIndex

String _walletExposureHDToKey(
        String walletId, NodeExposure exposure, int hdIndex) =>
    '$walletId:$exposure:$hdIndex';

class _WalletExposureHDKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletExposureHDToKey(
      address.walletId, address.exposure, address.hdIndex);
}

extension ByWalletExposureHDMethodsForAddress
    on Index<_WalletExposureHDKey, Address> {
  Address? getOne(String walletId, NodeExposure exposure, int hdIndex) =>
      getByKeyStr(_walletExposureHDToKey(walletId, exposure, hdIndex))
          .firstOrNull;
}

// byWallet

String _walletChainToKey(String walletId, Chain chain) => '$walletId:$chain';

class _WalletChainKey extends Key<Address> {
  @override
  String getKey(Address address) =>
      _walletChainToKey(address.walletId, address.chain);
}

extension ByWalletChainMethodsForAddress on Index<_WalletChainKey, Address> {
  List<Address> getAll(String walletId, Chain chain) =>
      getByKeyStr(_walletChainToKey(walletId, chain));
}

// byWalletExposure

String _walletChainExposureToKey(
        String walletId, Chain chain, Net net, NodeExposure exposure) =>
    '$walletId:${chain.name}:${net.name}:$exposure';

class _WalletChainExposureKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletChainExposureToKey(
      address.walletId, address.chain, address.net, address.exposure);
}

extension ByWalletChainExposureMethodsForAddress
    on Index<_WalletChainExposureKey, Address> {
  List<Address> getAll(
          String walletId, Chain chain, Net net, NodeExposure exposure) =>
      getByKeyStr(_walletChainExposureToKey(walletId, chain, net, exposure));
}

// byWalletExposureIndex

String _walletChainExposureHDToKey(String walletId, Chain chain, Net net,
        NodeExposure exposure, int hdIndex) =>
    '$walletId:${chain.name}:${net.name}:$exposure:$hdIndex';

class _WalletChainExposureHDKey extends Key<Address> {
  @override
  String getKey(Address address) => _walletChainExposureHDToKey(
      address.walletId,
      address.chain,
      address.net,
      address.exposure,
      address.hdIndex);
}

extension ByWalletChainExposureHDMethodsForAddress
    on Index<_WalletChainExposureHDKey, Address> {
  Address? getOne(String walletId, Chain chain, Net net, NodeExposure exposure,
          int hdIndex) =>
      getByKeyStr(_walletChainExposureHDToKey(
              walletId, chain, net, exposure, hdIndex))
          .firstOrNull;
}
