import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'transaction.keys.dart';

class TransactionReservoir extends Reservoir<_TxHashKey, Transaction> {
  late IndexMultiple<_ScripthashKey, Transaction> byScripthash;
  late IndexMultiple<_HeightKey, Transaction> byHeight;
  late IndexMultiple<_AddressKey, Transaction> byAddress;
  late IndexMultiple<_ConfirmedKey, Transaction> byConfirmed;

  TransactionReservoir() : super(_TxHashKey()) {
    byAddress = addIndexMultiple('address', _AddressKey());
    byScripthash = addIndexMultiple('scripthash', _ScripthashKey());
    byHeight = addIndexMultiple('height', _HeightKey());
    byConfirmed = addIndexMultiple('confirmed', _ConfirmedKey());
  }

  /// remove logic ////////////////////////////////////////////////////////////

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
