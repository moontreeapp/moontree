import 'package:test/test.dart';

import 'package:raven_electrum_client/raven_electrum_client.dart';

void main() {
  group('electrum_client', () {
    test('get unspent', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
      var scripthash =
          'b3bbdf50410b85299f914d2c573a7cadc2133d8e6cc088dc400dd174937f86e1';
      var utxos = await client.getUnspent(scripthash: scripthash);
      expect(utxos, [
        ScripthashUnspent(
            txHash:
                '84ab4db04a5d32fc81025db3944e6534c4c201fcc93749da6d1e5ecf98355533',
            txPos: 1,
            height: 765913,
            value: 5000087912000)
      ]);
    });

    test('withBatch', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');

      var scripthash =
          '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';

      var futures = <Future>[];
      client.peer.withBatch(() {
        futures.add(client.getHistory(scripthash: scripthash));
        futures.add(client.features());
      });
      var results = await Future.wait(futures);

      var features = results[1];
      expect(features['genesis_hash'],
          '000000ecfc5e6324a079542221d00e10362bdc894d56500c414060eea8a3ad5a');

      var history = results[0];
      expect(history, [
        ScripthashHistory(
            txHash:
                '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
            height: 747308),
        ScripthashHistory(
            txHash:
                '2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5',
            height: 769767)
      ]);
    });
  });
}
