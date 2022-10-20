part of 'vin.dart';

// primary key

class _IdKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.id;
}

extension ByIdMethodsForVin on Index<_IdKey, Vin> {
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
  Vin? getOneDetails(String voutTransactionId, int position) =>
      getByKeyStr(Vout.getVoutId(voutTransactionId, position)).firstOrNull;
}

// byIsCoinbase

class _IsCoinbaseKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.isCoinbase.toString();
}

extension ByIsCoinbaseMethodsForVin on Index<_IsCoinbaseKey, Vin> {
  List<Vin> getAll(bool isCoinbase) => getByKeyStr(isCoinbase.toString());
}

// byVoutTransactionId

class _VoutTransactionIdKey extends Key<Vin> {
  @override
  String getKey(Vin vin) => vin.voutTransactionId;
}

extension ByVoutTransactionIdMethodsForVin
    on Index<_VoutTransactionIdKey, Vin> {
  List<Vin> getAll(String voutTransactionId) => getByKeyStr(voutTransactionId);
}
