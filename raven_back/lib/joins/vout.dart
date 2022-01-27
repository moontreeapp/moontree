part of 'joins.dart';

// Joins on Vout (adds to my value, consumed in whole)

extension VoutBelongsToTransaction on Vout {
  Transaction? get transaction =>
      globals.res.transactions.primaryIndex.getOne(transactionId);
}

extension VoutBelongsToVin on Vout {
  Vin? get vin =>
      globals.res.vins.byVoutId.getOne(Vout.getVoutId(transactionId, position));
  // no vin - this is a unspent output
}

extension VoutHasOneSecurity on Vout {
  Security? get security => assetSecurityId == null
      ? globals.res.securities.RVN
      : globals.res.securities.primaryIndex.getOne(assetSecurityId!);
}

extension VoutBelongsToAddress on Vout {
  Address? get address => globals.res.addresses.byAddress.getOne(toAddress);
  // no address - we don't own this vout (we sent it to someone else)
}

extension VoutBelongsToWallet on Vout {
  Wallet? get wallet => address?.wallet;
  // no wallet - we don't own this vout
}

extension VoutBelongsToAccount on Vout {
  Account? get account => wallet?.account;
  // no account - we don't own this vout
}
