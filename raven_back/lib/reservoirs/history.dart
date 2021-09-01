import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

part 'history.keys.dart';

class HistoryReservoir extends Reservoir<_TxHashKey, History> {
  late IndexMultiple<_AccountKey, History> byAccount;
  late IndexMultiple<_WalletKey, History> byWallet;
  late IndexMultiple<_ScripthashKey, History> byScripthash;
  late IndexMultiple<_SecurityKey, History> bySecurity;

  HistoryReservoir([source])
      : super(source ?? HiveSource('histories'), _TxHashKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byScripthash = addIndexMultiple('scripthash', _ScripthashKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
  }

  /// Master overview /////////////////////////////////////////////////////////

  Iterable<History> unspentsByTicker({Security security = RVN}) {
    return bySecurity.getAll(security).where((history) => history.value > 0);
  }

  BalanceRaw balanceByTicker({Security security = RVN}) {
    return unspentsByTicker(security: security).fold(
        BalanceRaw(confirmed: 0, unconfirmed: 0),
        (sum, history) =>
            sum +
            BalanceRaw(
                confirmed: (history.position > -1 ? history.value : 0),
                unconfirmed: history.value));
  }

  /// remove logic ////////////////////////////////////////////////////////////

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
