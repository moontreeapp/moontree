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

extension TransactionBelongsToAccount on Transaction {
  Set<Account?>? get accounts => (vouts.map((vout) => vout.account).toList() +
          vins.map((vin) => vin.account).toList())
      .toSet()
    ..remove(null);
}

extension TransactionHasManyVins on Transaction {
  List<Vin> get vins => res.vins.byTransaction.getAll(transactionId);
}

extension TransactionHasManyVouts on Transaction {
  List<Vout> get vouts => res.vouts.byTransaction.getAll(transactionId);
}

extension TransactionHasManyMemos on Transaction {
  List<String> get memos => res.vouts.byTransaction
      .getAll(transactionId)
      .map((vout) => vout.memo)
      .toList();
}

extension TransactionHasOneValue on Transaction {
  int get value => res.vouts.byTransaction
      .getAll(transactionId)
      .map((vout) => vout.rvnValue)
      .toList()
      .sumInt();
}
