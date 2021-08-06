import 'package:raven/reservoir/index.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/history.dart';
import 'package:raven/reservoir/reservoir.dart';

class HistoryReservoir<Record, Model> extends Reservoir {
  late MultipleIndex byAccount;
  late MultipleIndex byWallet;
  late MultipleIndex byScripthash;

  HistoryReservoir() : super(HiveSource('histories')) {
    addPrimaryIndex((histories) => histories.txHash);

    byAccount = addMultipleIndex('account', (history) => history.accountId);
    byWallet = addMultipleIndex('wallet', (history) => history.walletId);
    byScripthash =
        addMultipleIndex('scripthash', (history) => history.scripthash);
  }

  /// returns account addresses in order
  OrderedSet<History>? unspentsByAccount(String accountId) {
    return byAccount
            .getAll(accountId)
            .where((element) => (element as History).value != null)
        as OrderedSet<History>;
  }

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
