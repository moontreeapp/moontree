import 'package:test/test.dart';
import 'package:timing/timing.dart';

import 'package:raven_electrum/raven_electrum.dart';

void main() {
  group('ElectrumClient', () {
    test('batched requests is fast', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');

      var scripthash =
          '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';

      var tracker = AsyncTimeTracker();
      var futures = <Future>[];
      List? results;
      await tracker.track(() async {
        client.peer.withBatch(() {
          for (var i = 0; i < 25; i++) {
            futures.add(client.getHistory(scripthash));
          }
        });
        results = await Future.wait(futures);
      });
      print(tracker.duration);
      expect(tracker.duration < Duration(seconds: 1), true);
      expect(results!.length, 25);
    });

    test('without batching', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');

      var scripthash =
          '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';

      var tracker = AsyncTimeTracker();
      await tracker.track(() async {
        for (var i = 0; i < 25; i++) {
          await client.getHistory(scripthash);
        }
      });
      print(tracker.duration);
      //expect(tracker.duration < Duration(seconds: 1), true);
    });

    test('batched Transactions requests is fast', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
      var txid =
          '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae';
      var tracker = AsyncTimeTracker();
      await tracker.track(() async {
        await client.getTransactions([for (var i = 0; i < 25; i++) txid]);
      });
      print(tracker.duration);
      //expect(tracker.duration < Duration(seconds: 1), true);
    });
    test('not batched Transactions requests costs', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
      var txid =
          '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae';
      var tracker = AsyncTimeTracker();
      await tracker.track(() async {
        for (var i = 0; i < 25; i++) {
          await client.getTransaction(txid);
        }
      });
      print(tracker.duration);
      //expect(tracker.duration < Duration(seconds: 1), true);
    });
  });
}
