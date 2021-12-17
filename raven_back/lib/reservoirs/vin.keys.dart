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
  String getKey(Vin vin) => vin.transactionId;
}

extension ByTransactionMethodsForVin on Index<_TransactionKey, Vin> {
  List<Vin> getAll(String transactionId) => getByKeyStr(transactionId);
}

// byVout

class _VoutIdKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.voutId;
}

extension ByVoutIdMethodsForVin on Index<_VoutIdKey, Vin> {
  Vin? getOne(String voutId) => getByKeyStr(voutId).firstOrNull;
}

// byIsCoinbase

class _IsCoinbaseKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.isCoinbase.toString();
}

extension ByIsCoinbaseMethodsForVin on Index<_IsCoinbaseKey, Vin> {
  List<Vin> getAll(bool isCoinbase) => getByKeyStr(isCoinbase.toString());
}
