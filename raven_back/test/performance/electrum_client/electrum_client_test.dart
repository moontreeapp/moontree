import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:timing/timing.dart';

import 'package:raven/electrum_client.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven/env.dart' as env;

void main() {
  group('ElectrumClient', () {
    test('batched requests is fast', () async {
      var client = await ElectrumClient.connect('testnet.rvn.rocks');

      var account = Account(ravencoinTestnet,
          seed: bip39.mnemonicToSeed(
              'smile build brain topple moon scrap area aim budget enjoy polar erosion'));
      var scriptHash =
          account.node(4, exposure: NodeExposure.Internal).scriptHash;

      var tracker = AsyncTimeTracker();
      var futures = <Future>[];
      var results;
      await tracker.track(() async {
        client.peer.withBatch(() {
          for (var i = 0; i < 25; i++) {
            futures.add(client.getHistory(scriptHash: scriptHash));
          }
        });
        results = await Future.wait(futures);
      });
      expect(tracker.duration < Duration(seconds: 1), true);
      expect(results.length, 25);
    });
  });
}
