import 'package:raven_electrum/raven_electrum.dart';
import 'package:reservoir/reservoir.dart';
import 'package:raven_back/raven_back.dart';

class MockHistories {
  bool handledFirstRecord = false;

  void init() {
    addresses.batchedChanges.listen((List<Change<Address>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
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
    //await services.address.saveScripthashHistoryData(ScripthashHistoriesData(
    //  [address.scripthash],
    //  [
    //    [ScripthashHistory(height: 0, txHash: 'abc1')]
    //  ],
    //  [
    //    [
    //      ScripthashUnspent(
    //          height: 0,
    //          txHash: 'abc2',
    //          scripthash: address.scripthash,
    //          txPos: 0,
    //          value: 1000000000)
    //    ]
    //  ],
    //  [
    //    [
    //      ScripthashUnspent(
    //          height: 0,
    //          txHash: 'abc3',
    //          scripthash: address.scripthash,
    //          txPos: 0,
    //          value: 5000000000,
    //          ticker: 'Magic Musk')
    //    ]
    //  ],
    //));
  }
}