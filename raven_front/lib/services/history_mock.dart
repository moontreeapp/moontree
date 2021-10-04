import 'package:raven/services/address.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:reservoir/reservoir.dart';
import 'package:raven/raven.dart';

class MockHistories {
  bool handledFirstRecord = false;

  void init() {
    addresses.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              var address = added.data;
              if (!handledFirstRecord) {
                handledFirstRecord = true;
                makeFakeHistories(address);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    });
  }

  void makeFakeHistories(Address address) async {
    await services.addresses.saveScripthashHistoryData(ScripthashHistoriesData(
      [address.scripthash],
      [
        [ScripthashHistory(height: 0, txHash: 'abc1')]
      ],
      [
        [
          ScripthashUnspent(
              height: 0,
              txHash: 'abc2',
              scripthash: address.scripthash,
              txPos: 0,
              value: 1000000000)
        ]
      ],
      [
        [
          ScripthashUnspent(
              height: 0,
              txHash: 'abc3',
              scripthash: address.scripthash,
              txPos: 0,
              value: 5000000000,
              ticker: 'Magic Musk')
        ]
      ],
      [
        ['memo1', 'memo2'],
        ['memo3']
      ],
    ));
  }
}
