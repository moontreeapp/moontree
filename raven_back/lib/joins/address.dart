part of 'joins.dart';

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension AddressBelongsToAccount on Address {
  Account? get account => wallet?.account;
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => globals.vouts.byScripthash.getAll(addressId);
}

extension AddressHasManyVins on Address {
  List<Vin> get vins => globals.vins.byScripthash.getAll(addressId);
}

extension AddressHasManyTransactions on Address {
  Set<Transaction> get transactions =>
      (this.vouts.map((vout) => vout.transaction!).toList() +
              this.vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
}
