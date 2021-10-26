part of 'joins.dart';

// Joins on Vout (adds to my value, consumed in whole)

extension VoutBelongsToTransaction on Vout {
  Transaction? get transaction =>
      globals.transactions.primaryIndex.getOne(txId);
}

extension VoutBelongsToVin on Vout {
  Vin? get vin => globals.vins.byVoutId.getOne(Vout.getVoutId(txId, position));
  // no vin - this is a unspent output
}

extension VoutHasOneSecurity on Vout {
  Security? get security => assetSecurityId == null
      ? null
      : globals.securities.primaryIndex.getOne(assetSecurityId!);
}

extension VoutBelongsToAddress on Vout {
  Address? get address => globals.addresses.byAddress.getOne(toAddress);
  // no address - we don't own this vout
}

extension VoutBelongsToWallet on Vout {
  Wallet? get wallet => address?.wallet;
  // no wallet - we don't own this vout
}

extension VoutBelongsToAccount on Vout {
  Account? get account => wallet?.account;
  // no account - we don't own this vout
}
