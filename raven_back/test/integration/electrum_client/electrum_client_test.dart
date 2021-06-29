import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/electrum_client.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven/env.dart' as env;

void main() {
  group('ElectrumClient', () {
    test('withBatch', () async {
      var client = await ElectrumClient.connect('testnet.rvn.rocks');

      // var phrase = await env.getMnemonic();
      var account = Account(ravencoinTestnet,
          seed: bip39.mnemonicToSeed(
              'smile build brain topple moon scrap area aim budget enjoy polar erosion'));
      var scriptHash =
          account.node(4, exposure: NodeExposure.Internal).scriptHash;

      var futures = <Future>[];
      client.peer.withBatch(() {
        futures.add(client.getHistory(scriptHash: scriptHash));
        futures.add(client.features());
      });
      var results = await Future.wait(futures);

      var features = results[1];
      expect(features['genesis_hash'],
          '000000ecfc5e6324a079542221d00e10362bdc894d56500c414060eea8a3ad5a');

      var history = results[0];
      expect(history, [
        ScriptHashHistory(
            txHash:
                '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
            height: 747308),
        ScriptHashHistory(
            txHash:
                '2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5',
            height: 769767)
      ]);
    });
  });
}
