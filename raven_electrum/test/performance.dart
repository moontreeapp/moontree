import 'package:test/test.dart';
import 'package:timing/timing.dart';

import 'package:raven_electrum_client/raven_electrum_client.dart';

void main() {
  group('ElectrumClient', () {
    test('batched requests is fast', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');

      var scripthash =
          '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';

      var tracker = AsyncTimeTracker();
      var futures = <Future>[];
      var results;
      await tracker.track(() async {
        client.peer.withBatch(() {
          for (var i = 0; i < 25; i++) {
            futures.add(client.getHistory(scripthash: scripthash));
          }
        });
        results = await Future.wait(futures);
      });
      expect(tracker.duration < Duration(seconds: 1), true);
      expect(results.length, 25);
    });
  });
}
