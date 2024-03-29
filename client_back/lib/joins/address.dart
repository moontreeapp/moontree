part of 'joins.dart';

extension AddressHasOneStatus on Address {
  Status? get status => pros.statuses.primaryIndex.getOneByAddress(this);
}

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => pros.wallets.primaryIndex.getOne(walletId);
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => pros.vouts.byAddress
      .getAll(address(pros.settings.chain, pros.settings.net));
}

extension AddressHasManyUnspents on Address {
  List<Unspent> get unspents => pros.unspents.byAddress
      .getAll(address(pros.settings.chain, pros.settings.net));
}
