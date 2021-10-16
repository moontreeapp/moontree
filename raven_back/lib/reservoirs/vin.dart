import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'vin.keys.dart';

class VinReservoir extends Reservoir<_VinIdKey, Vin> {
  late IndexMultiple<_TransactionKey, Vin> byTransaction;

  VinReservoir() : super(_VinIdKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
  }
}
