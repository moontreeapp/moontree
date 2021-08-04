import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/history.dart';
import 'package:raven/reservoir/reservoir.dart';

class HistoryReservoir<Record, Model> extends Reservoir {
  HistoryReservoir([source, mapToModel, mapToRecord])
      : super(source ?? HiveBoxSource('histories'),
            (histories) => histories.txHash, [mapToModel, mapToRecord]) {
    addIndex('account', (history) => history.accountId);
    addIndex('wallet', (history) => history.walletId);
    addIndex('scripthash', (history) => history.scripthash);
  }

  /// returns account addresses in order
  OrderedSet<History>? byWallet(String walletId) {
    return indices['wallet']!.getAll(walletId) as OrderedSet<History>;
  }

  /// returns account addresses in order
  OrderedSet<History>? byAccount(String accountId) {
    return indices['account']!.getAll(accountId) as OrderedSet<History>;
  }

  /// returns account addresses in order
  OrderedSet<History>? unspentsByAccount(String accountId) {
    return indices['account']!
            .getAll(accountId)
            .where((element) => (element as History).value != null)
        as OrderedSet<History>;
  }

  void removeHistories(String scripthash) {
    return indices['scripthash']!
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
