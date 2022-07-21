part of 'joins.dart';

extension WalletBelongsToCipher on Wallet {
  //CipherBase? get cipher => pros.cipherRegistry.ciphers[cipherUpdate];
  CipherBase? get cipher => cipherUpdate.cipherType == CipherType.None
      ? pros.ciphers.records.firstOrNull?.cipher
      : pros.ciphers.primaryIndex.getOne(cipherUpdate)?.cipher;
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses => pros.addresses.byWallet.getAll(id);
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
  Set<Transaction> get transactions =>
      (vouts.map((vout) => vout.transaction!).toList() +
              vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
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
      addresses.where((address) => address.exposure == NodeExposure.Internal);
}

// receive addresses
extension WalletHasManyExternalAddresses on Wallet {
  Iterable<Address> get externalAddresses =>
      addresses.where((address) => address.exposure == NodeExposure.External);
}

extension WalletHasManyEmptyInternalAddresses on Wallet {
  Iterable<Address> get emptyInternalAddresses =>
      internalAddresses.where((address) => address.vouts.isEmpty);
}

extension WalletHasManyEmptyExternalAddresses on Wallet {
  Iterable<Address> get emptyExternalAddresses =>
      externalAddresses.where((address) => address.vouts.isEmpty);
}

extension WalletHasManyUsedInternalAddresses on Wallet {
  Iterable<Address> get usedInternalAddresses =>
      internalAddresses.where((address) => address.vouts.isNotEmpty);
}

extension WalletHasManyUsedExternalAddresses on Wallet {
  Iterable<Address> get usedExternalAddresses =>
      externalAddresses.where((address) => address.vouts.isNotEmpty);
}
/* unused
*/
