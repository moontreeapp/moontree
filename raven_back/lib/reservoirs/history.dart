import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'history.keys.dart';

class HistoryReservoir extends Reservoir<_TxHashKey, History> {
  late IndexMultiple<_ScripthashKey, History> byScripthash;
  late IndexMultiple<_SecurityKey, History> bySecurity;
  late IndexMultiple<_AddressKey, History> byAddress;

  HistoryReservoir() : super(_TxHashKey()) {
    byAddress = addIndexMultiple('address', _AddressKey());
    byScripthash = addIndexMultiple('scripthash', _ScripthashKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
  }

  /// makeshiftIndicies ///////////////////////////////////////////////////////

  static Iterable<History> whereTransaction(
          {Iterable<History>? given, Security? security}) =>
      (given ?? histories).where((history) =>
          history.confirmed && // not in mempool
          (security != null ? history.security == security : true));

  static Iterable<History> whereUnspent(
          {Iterable<History>? given, Security? security}) =>
      (given ?? histories).where((history) =>
          history.value > 0 && // unspent
          history.confirmed && // not in mempool
          (security != null ? history.security == security : true));

  static Iterable<History> whereUnconfirmed(
          {Iterable<History>? given, Security? security}) =>
      (given ?? histories).where((history) =>
          history.value > 0 && // unspent
          !history.confirmed && // in mempool
          (security != null ? history.security == security : true));

  /// remove logic ////////////////////////////////////////////////////////////

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
