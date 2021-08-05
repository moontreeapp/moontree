import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class HistoryReservoir<Record, Model> extends Reservoir {
  late MultipleIndex byAccount;
  late MultipleIndex byScripthash;

  HistoryReservoir() : super(HiveSource('histories')) {
    addPrimaryIndex((histories) => histories.txHash);

    byAccount = addMultipleIndex('account', (history) => history.accountId);
    byScripthash =
        addMultipleIndex('scripthash', (history) => history.scripthash);
  }

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
