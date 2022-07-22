import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'vin.keys.dart';

class VinProclaim extends Proclaim<_VinIdKey, Vin> {
  late IndexMultiple<_TransactionKey, Vin> byTransaction;
  late IndexMultiple<_IsCoinbaseKey, Vin> byIsCoinbase;
  late IndexMultiple<_VoutIdKey, Vin> byVoutId;
  late IndexMultiple<_VoutTransactionIdKey, Vin> byVoutTransactionId;

  VinProclaim() : super(_VinIdKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    byIsCoinbase = addIndexMultiple('isCoinbase', _IsCoinbaseKey());
    byVoutId = addIndexMultiple('vout', _VoutIdKey());
    byVoutTransactionId =
        addIndexMultiple('voutTransaction', _VoutTransactionIdKey());
  }

  Iterable<Vin> get danglingVins => records.where((vin) => vin.vout == null);
}
