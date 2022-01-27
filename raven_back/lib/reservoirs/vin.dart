import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'vin.keys.dart';

class VinReservoir extends Reservoir<_VinIdKey, Vin> {
  late IndexMultiple<_TransactionKey, Vin> byTransaction;
  late IndexMultiple<_IsCoinbaseKey, Vin> byIsCoinbase;
  late IndexMultiple<_VoutIdKey, Vin> byVoutId;
  late IndexMultiple<_VoutTransactionIdKey, Vin> byVoutTransactionId;

  VinReservoir() : super(_VinIdKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    byIsCoinbase = addIndexMultiple('isCoinbase', _IsCoinbaseKey());
    byVoutId = addIndexMultiple('vout', _VoutIdKey());
    byVoutTransactionId =
        addIndexMultiple('voutTransaction', _VoutTransactionIdKey());
  }

  Iterable<Vin> get danglingVins => data.where((vin) => vin.vout == null);
}
