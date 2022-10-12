part of 'joins.dart';

// Joins on Vout (adds to my value, consumed in whole)

extension VoutBelongsToTransaction on Vout {
  Transaction? get transaction =>
      pros.transactions.primaryIndex.getOne(transactionId);
}

extension VoutBelongsToVin on Vout {
  Vin? get vin =>
      pros.vins.byVoutId.getOne(Vout.key(transactionId, position, chain, net));
  // no vin - this is a unspent output
}

extension VoutHasOneSecurity on Vout {
  Security? get security => assetSecurityId == null
      ? pros.securities.RVN
      : pros.securities.primaryIndex.getOne(assetSecurityId!);
  // if this is not found we should go get it,
  // because this should never not be found.
}

extension VoutBelongsToAddress on Vout {
  Address? get address =>
      toAddress != null ? pros.addresses.byAddress.getOne(toAddress!) : null;
  // no address - we don't own this vout (we sent it to someone else)
}

extension VoutBelongsToWallet on Vout {
  Wallet? get wallet => address?.wallet;
  // no wallet - we don't own this vout
}
