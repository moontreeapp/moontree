part of 'joins.dart';

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension AddressBelongsToAccount on Address {
  Account? get account => wallet?.account;
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => globals.vouts.byAddress.getAll(address);
}
