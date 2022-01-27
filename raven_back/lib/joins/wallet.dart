part of 'joins.dart';

extension WalletBelongsToCipher on Wallet {
  //CipherBase? get cipher => globals.res.cipherRegistry.ciphers[cipherUpdate];
  CipherBase? get cipher => cipherUpdate.cipherType == CipherType.None
      ? globals.res.ciphers.data.firstOrNull?.cipher
      : globals.res.ciphers.primaryIndex.getOne(cipherUpdate)?.cipher;
}

extension WalletBelongsToAccount on Wallet {
  Account? get account => globals.res.accounts.primaryIndex.getOne(accountId);
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses =>
      globals.res.addresses.byWallet.getAll(walletId);
}

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

extension WalletHasManyBalances on Wallet {
  List<Balance> get balances => globals.res.balances.byWallet.getAll(walletId);
}

extension WalletHasManyVouts on Wallet {
  Iterable<Vout> get vouts =>
      globals.res.vouts.data.where((vout) => vout.wallet?.walletId == walletId);
}

extension WalletHasManyVins on Wallet {
  Iterable<Vin> get vins =>
      globals.res.vins.data.where((vin) => vin.wallet?.walletId == walletId);
}

extension WalletHasManyTransactions on Wallet {
  Set<Transaction> get transactions =>
      (vouts.map((vout) => vout.transaction!).toList() +
              vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
}
