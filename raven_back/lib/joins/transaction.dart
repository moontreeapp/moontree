part of 'joins.dart';

// Joins on Transaction

extension TransactionBelongsToAddress on Transaction {
  Set<Address?>? get addresses => (vouts.map((vout) => vout.address).toList() +
          vins.map((vin) => vin.address).toList())
      .toSet()
    ..remove(null);
}

extension TransactionBelongsToWallet on Transaction {
  Set<Wallet?>? get wallets => (vouts.map((vout) => vout.wallet).toList() +
          vins.map((vin) => vin.wallet).toList())
      .toSet()
    ..remove(null);
}

extension TransactionHasManyVins on Transaction {
  List<Vin> get vins => res.vins.byTransaction.getAll(id);
}

extension TransactionHasManyVouts on Transaction {
  List<Vout> get vouts => res.vouts.byTransaction.getAll(id);
}

extension TransactionHasManyMemos on Transaction {
  List<String> get memos =>
      res.vouts.byTransaction.getAll(id).map((vout) => vout.memo).toList();
}

extension TransactionHasOneValue on Transaction {
  int get value => res.vouts.byTransaction
      .getAll(id)
      .map((vout) => vout.rvnValue)
      .toList()
      .sumInt();
}
