import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'vin.keys.dart';

class VinReservoir extends Reservoir<_VinIdKey, Vin> {
  late IndexMultiple<_TransactionKey, Vin> byTransaction;
  late IndexMultiple<_ScripthashKey, Vin> byScripthash;

  VinReservoir() : super(_VinIdKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    byScripthash = addIndexMultiple('address', _ScripthashKey());
  }

  Iterable<Vin> get danglingVins => data.where((vin) => vin.vout == null);
}
