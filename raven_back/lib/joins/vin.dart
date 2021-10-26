part of 'joins.dart';
// Joins on Vin (input to new transcation, points to 1 pre-existing vout)

extension VinBelongsToTransaction on Vin {
  Transaction? get transaction =>
      globals.transactions.primaryIndex.getOne(txId);
}

extension VinHasOneVout on Vin {
  Vout? get vout =>
      globals.vouts.primaryIndex.getOne(Vout.getVoutId(voutTxId, voutPosition));
}

extension VinHasOneSecurity on Vin {
  Security? get security => vout?.security;
}

extension VinHasOneValue on Vin {
  int? get value => vout?.value;
}

extension VinBelongsToAddress on Vin {
  Address? get address => vout?.address;
}

extension VinBelongsToWallet on Vin {
  Wallet? get wallet => address?.wallet;
}

extension VinBelongsToAccount on Vin {
  Account? get account => wallet?.account;
}
