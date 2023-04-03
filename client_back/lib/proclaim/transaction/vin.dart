import 'package:collection/collection.dart';
import 'package:client_back/client_back.dart';
import 'package:proclaim/proclaim.dart';

part 'vin.keys.dart';

class VinProclaim extends Proclaim<_IdKey, Vin> {
  late IndexMultiple<_TransactionKey, Vin> byTransaction;
  late IndexMultiple<_IsCoinbaseKey, Vin> byIsCoinbase;
  late IndexMultiple<_VoutIdKey, Vin> byVoutId;
  late IndexMultiple<_VoutTransactionIdKey, Vin> byVoutTransactionId;

  VinProclaim() : super(_IdKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    byIsCoinbase = addIndexMultiple('isCoinbase', _IsCoinbaseKey());
    byVoutId = addIndexMultiple('vout', _VoutIdKey());
    byVoutTransactionId =
        addIndexMultiple('voutTransaction', _VoutTransactionIdKey());
  }

  Iterable<Vin> get dangling => records.where((Vin vin) => vin.vout == null);
  Iterable<Vin> danglingOf(List<Vin> vins) =>
      vins.where((Vin vin) => vin.vout == null);
}
