part of 'joins.dart';

extension WalletBelongsToCipher on Wallet {
  //CipherBase? get cipher => globals.cipherRegistry.ciphers[cipherUpdate];
  CipherBase? get cipher =>
      globals.ciphers.primaryIndex.getOne(cipherUpdate)?.cipher;
}

extension WalletBelongsToAccount on Wallet {
  Account? get account => globals.accounts.primaryIndex.getOne(accountId);
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses => globals.addresses.byWallet.getAll(walletId);
}

extension WalletHasManyBalances on Wallet {
  List<Balance> get balances => globals.balances.byWallet.getAll(walletId);
}

extension WalletHasManyVouts on Wallet {
  Iterable<Vout> get vouts =>
      globals.vouts.data.where((vout) => vout.wallet?.walletId == walletId);
}

extension WalletHasManyVins on Wallet {
  Iterable<Vin> get vins =>
      globals.vins.data.where((vin) => vin.wallet?.walletId == walletId);
}

extension WalletHasManyTransactions on Wallet {
  Set<Transaction> get transactions =>
      (this.vouts.map((vout) => vout.transaction!).toList() +
              this.vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
}
