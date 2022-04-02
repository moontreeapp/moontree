part of 'joins.dart';

extension AddressBelongsToWallet on Address {
  Wallet get wallet => res.wallets.primaryIndex.getOne(walletId)!;
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => res.vouts.byAddress.getAll(address);
}
