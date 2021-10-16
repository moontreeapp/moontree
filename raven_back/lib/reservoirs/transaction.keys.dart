part of 'transaction.dart';

// primary key

class _TxHashKey extends Key<Transaction> {
  @override
  String getKey(Transaction transaction) => transaction.txId;
}

extension ByIdMethodsForTransaction on Index<_TxHashKey, Transaction> {
  Transaction? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byAddress

class _AddressKey extends Key<Transaction> {
  @override
  String getKey(Transaction transaction) => transaction.address?.address ?? '';
}

extension ByAddressMethodsForTransaction on Index<_AddressKey, Transaction> {
  List<Transaction> getAll(String address) => getByKeyStr(address);
}

// byScripthash

class _ScripthashKey extends Key<Transaction> {
  @override
  String getKey(Transaction transaction) => transaction.addressId;
}

extension ByScripthashMethodsForTransaction
    on Index<_ScripthashKey, Transaction> {
  List<Transaction> getAll(String addressId) => getByKeyStr(addressId);
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
  String getKey(Transaction history) => history.confirmed.toString();
}

extension ByConfrimedMethodsForTransaction
    on Index<_ConfirmedKey, Transaction> {
  List<Transaction> getAll(bool confirmed) => getByKeyStr(confirmed.toString());
}
