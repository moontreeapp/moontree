part of 'joins.dart';

extension WalletBelongsToCipher on Wallet {
  //CipherBase? get cipher => pros.cipherRegistry.ciphers[cipherUpdate];
  CipherBase? get cipher => cipherUpdate.cipherType == CipherType.none
      ? pros.ciphers.records.firstOrNull?.cipher
      : pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)?.cipher;
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses => pros.addresses.byWallet.getAll(id);
}

extension WalletHasManyAddressesByExposure on Wallet {
  List<Address> addressesBy(NodeExposure exposure) =>
      pros.addresses.byWalletExposure.getAll(id, exposure);
}

extension WalletHasOneHighestIndexByExposure on Wallet {
  int highestIndexOf(NodeExposure exposure) => addressesBy(exposure).fold(
      -1,
      (previousValue, element) =>
          element.hdIndex > previousValue ? element.hdIndex : previousValue);
}

extension WalletHasManyBalances on Wallet {
  List<Balance> get balances => pros.balances.byWallet.getAll(id);
}

extension WalletHasManyVouts on Wallet {
  Iterable<Vout> get vouts =>
      pros.vouts.records.where((vout) => vout.wallet?.id == id);
}

extension WalletHasManyVins on Wallet {
  Iterable<Vin> get vins =>
      pros.vins.records.where((vin) => vin.wallet?.id == id);
}

extension WalletHasManyTransactions on Wallet {
  Set<Transaction> get transactions {
    try {
      return (vouts.map((vout) => vout.transaction!).toList() +
              vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
    } catch (e) {
      return <Transaction>{};
    }
  }
}

// would prefer .assets
extension WalletHasManyHoldingCount on Wallet {
  int get holdingCount => vouts
      .map((Vout vout) => vout.assetSecurityId // null is rvn
          )
      .toSet()
      .length;
}

extension WalletHasRVNValue on Wallet {
  int get RVNValue => balances
      .where((Balance b) => b.security.symbol == 'RVN')
      .fold(0, (running, Balance b) => b.value + running);
}

//extension WalletHasAssetValue on Wallet {
//  int get assetValue(Asset asset) => balances
//      .where((Balance b) => b.security.symbol == 'RVN')
//      .fold(0, (running, Balance b) => b.value + running);
//}

// change addresses
extension WalletHasManyInternalAddresses on Wallet {
  Iterable<Address> get internalAddresses =>
      addresses.where((address) => address.exposure == NodeExposure.internal);
}

// receive addresses
extension WalletHasManyExternalAddresses on Wallet {
  Iterable<Address> get externalAddresses =>
      addresses.where((address) => address.exposure == NodeExposure.external);
}

extension WalletHasManyGapAddresses on Wallet {
  Iterable<Address> usedAddresses(NodeExposure exposure) =>
      addresses.where((address) =>
          address.exposure == exposure && address.status?.status != null);

  Iterable<Address> emptyAddresses(NodeExposure exposure) =>
      addresses.where((address) =>
          address.exposure == exposure &&
          address.status != null &&
          address.status!.status == null);

  Address minimumEmptyAddress(NodeExposure exposure) {
    final x = emptyAddresses(exposure).toList();
    // KPWallets have only one address that is probably used
    if (x.isEmpty) return addresses.first;
    final y = x.fold(
        999999999,
        (int previousValue, Address element) =>
            element.hdIndex < previousValue ? element.hdIndex : previousValue);
    return x.where((element) => element.hdIndex == y).first;
  }

  Iterable<Address> emptyAddressesAfterIndex(
    NodeExposure exposure,
    int index,
  ) =>
      addresses.where((address) =>
          address.hdIndex > index &&
          address.exposure == exposure &&
          address.status?.status == null);

  int highestUsedIndex(NodeExposure exposure) =>
      usedAddresses(exposure).toList().fold(
          -1,
          (int previousValue, Address element) =>
              element.hdIndex > previousValue
                  ? element.hdIndex
                  : previousValue);

  Iterable<Address> gapAddresses(NodeExposure exposure) =>
      emptyAddressesAfterIndex(exposure, highestUsedIndex(exposure));

  Address firstEmptyInGap(NodeExposure exposure) {
    final gap = gapAddresses(exposure).toList();
    // KPWallets have only one address that is probably used
    if (gap.isEmpty) return addresses.first;
    final lowest = gap.fold(double.maxFinite.toInt(),
        (int prev, Address addr) => addr.hdIndex < prev ? addr.hdIndex : prev);
    return gap.where((element) => element.hdIndex == lowest).first;
  }
}

extension WalletHasManyEmptyInternalAddresses on Wallet {
  Iterable<Address> get emptyInternalAddresses => addresses.where((address) =>
      address.exposure == NodeExposure.internal &&
      address.status?.status == null);
  //internalAddresses.where((address) => address.vouts.isEmpty);
}

extension WalletHasManyEmptyExternalAddresses on Wallet {
  Iterable<Address> get emptyExternalAddresses => addresses.where((address) =>
      address.exposure == NodeExposure.external &&
      address.status?.status == null);
  //externalAddresses.where((address) => address.vouts.isEmpty);
}

extension WalletHasManyUsedInternalAddresses on Wallet {
  Iterable<Address> get usedInternalAddresses => addresses.where((address) =>
      address.exposure == NodeExposure.internal &&
      address.status?.status != null);
  //internalAddresses.where((address) => address.vouts.isNotEmpty);
}

extension WalletHasManyUsedExternalAddresses on Wallet {
  Iterable<Address> get usedExternalAddresses => addresses.where((address) =>
      address.exposure == NodeExposure.external &&
      address.status?.status != null);
  //externalAddresses.where((address) => address.vouts.isNotEmpty);
}

extension WalletHasManyUnspents on Wallet {
  List<Unspent> get unspents => pros.unspents.byWallet.getAll(id);
}
