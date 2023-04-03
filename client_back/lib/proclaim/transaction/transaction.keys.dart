part of 'transaction.dart';

// primary key

class _IdKey extends Key<Transaction> {
  @override
  String getKey(Transaction transaction) => transaction.id;
}

extension ByIdMethodsForTransaction on Index<_IdKey, Transaction> {
  Transaction? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byHeight

class _HeightKey extends Key<Transaction> {
  @override
  String getKey(Transaction transaction) => transaction.height.toString();
}

extension ByHeightMethodsForTransaction on Index<_HeightKey, Transaction> {
  List<Transaction> getAll(int height) => getByKeyStr(height.toString());
}

// byConfirmed

class _ConfirmedKey extends Key<Transaction> {
  @override
  String getKey(Transaction transaction) => transaction.confirmed.toString();
}

extension ByConfrimedMethodsForTransaction
    on Index<_ConfirmedKey, Transaction> {
  List<Transaction> getAll(bool confirmed) => getByKeyStr(confirmed.toString());
}
