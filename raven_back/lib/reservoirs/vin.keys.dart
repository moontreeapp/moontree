part of 'vin.dart';

// primary key

class _VinIdKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.vinId;
}

extension ByIdMethodsForVin on Index<_VinIdKey, Vin> {
  Vin? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byTransaction

class _TransactionKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.txId;
}

extension ByTransactionMethodsForVin on Index<_TransactionKey, Vin> {
  List<Vin> getAll(String txId) => getByKeyStr(txId);
}

// byVout

class _VoutIdKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.voutId;
}

extension ByVoutIdMethodsForVin on Index<_VoutIdKey, Vin> {
  Vin? getOne(String voutId) => getByKeyStr(voutId).firstOrNull;
}

// byTransaction

class _ScripthashKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.address?.addressId ?? '';
}

extension ByScripthashMethodsForVin on Index<_ScripthashKey, Vin> {
  List<Vin> getAll(String addressId) => getByKeyStr(addressId);
}
