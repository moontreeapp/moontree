part of 'joins.dart';

// Joins on Vin (input to new transcation, points to 1 pre-existing vout)

extension VinBelongsToTransaction on Vin {
  Transaction? get transaction =>
      pros.transactions.primaryIndex.getOne(transactionId);
}

extension VinHasOneVout on Vin {
  Vout? get vout =>
      pros.vouts.primaryIndex.getOne(Vout.key(voutTransactionId, voutPosition));
}

extension VinHasOneSecurity on Vin {
  Security? get security => vout?.security;
}

extension VinHasOneValue on Vin {
  int? get value => vout?.coinValue;
}

extension VinBelongsToAddress on Vin {
  Address? get address => vout?.address;
}

extension VinBelongsToWallet on Vin {
  Wallet? get wallet => address?.wallet;
}
