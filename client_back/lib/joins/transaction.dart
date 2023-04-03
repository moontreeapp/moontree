part of 'joins.dart';

// Joins on Transaction

extension TransactionBelongsToAddress on Transaction {
  Set<Address?>? get addresses =>
      (vouts.map((Vout vout) => vout.address).toList() +
              vins.map((Vin vin) => vin.address).toList())
          .toSet()
        ..remove(null);
}

extension TransactionBelongsToWallet on Transaction {
  Set<Wallet?>? get wallets => (vouts.map((Vout vout) => vout.wallet).toList() +
          vins.map((Vin vin) => vin.wallet).toList())
      .toSet()
    ..remove(null);
}

extension TransactionHasManyVins on Transaction {
  List<Vin> get vins => pros.vins.byTransaction.getAll(id);
}

extension TransactionHasManyVouts on Transaction {
  List<Vout> get vouts => pros.vouts.byTransaction.getAll(id);
}

extension TransactionHasManyMemos on Transaction {
  List<String> get memos => pros.vouts.byTransaction
      .getAll(id)
      .map((Vout vout) => vout.memo ?? '')
      .where((String m) => m != '')
      .toList();
}

extension TransactionHasManyAssetMemos on Transaction {
  List<String> get assetMemos => pros.vouts.byTransaction
      .getAll(id)
      .map((Vout vout) => vout.assetMemo ?? '')
      .where((String m) => m != '')
      .toList();
}

extension TransactionHasOneValue on Transaction {
  int get value => pros.vouts.byTransaction
      .getAll(id)
      .map((Vout vout) => vout.coinValue)
      .toList()
      .sumInt();
}

extension TransactionHasOneNote on Transaction {
  String? get note => pros.notes.primaryIndex.getOne(id)?.note;
}
