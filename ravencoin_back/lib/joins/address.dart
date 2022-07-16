part of 'joins.dart';

extension AddressHasOneStatus on Address {
  Status? get status => pros.statuses.byAddress.getOne(this);
}

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => pros.wallets.primaryIndex.getOne(walletId);
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => pros.vouts.byAddress.getAll(address);
}
