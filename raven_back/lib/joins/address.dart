part of 'joins.dart';

extension AddressHasOneStatus on Address {
  Status? get status => res.statuses.byAddress.getOne(this);
}

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => res.wallets.primaryIndex.getOne(walletId);
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => res.vouts.byAddress.getAll(address);
}
