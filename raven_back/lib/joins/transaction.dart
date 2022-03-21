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
  List<String> get memos => res.vouts.byTransaction
      .getAll(id)
      .map((Vout vout) => vout.memo)
      .where((String m) => m != '')
      .toList();
}

extension TransactionHasManyAssetMemos on Transaction {
  List<String> get assetMemos => res.vouts.byTransaction
      .getAll(id)
      .map((Vout vout) => vout.assetMemo)
      .where((String m) => m != '')
      .toList();
}

extension TransactionHasOneValue on Transaction {
  int get value => res.vouts.byTransaction
      .getAll(id)
      .map((vout) => vout.rvnValue)
      .toList()
      .sumInt();
}

extension TransactionHasOneNote on Transaction {
  String? get note => res.note.primaryIndex.getOne(id)?.note;
}
