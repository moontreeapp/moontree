import 'package:raven/reservoir/reservoir.dart';

class HistoryReservoir<Record, Model> extends Reservoir {
  HistoryReservoir([source, mapToModel, mapToRecord])
      : super(source ?? HiveBoxSource('histories'),
            (histories) => histories.txHash, [mapToModel, mapToRecord]) {
    addIndex('account', (history) => history.accountId);
    addIndex('scripthash', (history) => history.scripthash);
  }

  void removeHistories(String scripthash) {
    return indices['scripthash']!
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
