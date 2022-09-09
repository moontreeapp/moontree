part of 'joins.dart';

// Joins on Unspent (adds to my value, consumed in whole)

extension UnspentBelongsToTransaction on Unspent {
  Transaction? get transaction =>
      pros.transactions.primaryIndex.getOne(transactionId);
}

extension UnspentIsAVout on Unspent {
  Vout? get vout =>
      pros.vouts.byTransactionPosition.getOne(transactionId, position);
}

extension UnspentHasOneSecurity on Unspent {
  Security? get security => pros.securities.primaryIndex.getOne(symbol);
}

extension UnspentBelongsToAddress on Unspent {
  Address? get address => pros.addresses.byAddress.getOne(addressId);
}

extension UnspentBelongsToWallet on Unspent {
  Wallet? get wallet => pros.wallets.primaryIndex.getOne(walletId);
}
