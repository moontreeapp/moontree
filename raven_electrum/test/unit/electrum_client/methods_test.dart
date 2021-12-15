import 'package:test/test.dart';

import 'package:raven_electrum/raven_electrum.dart';

import '../mock_electrum_server.dart';

void main() {
  group('subscriptions', () {
    late MockElectrumServer server;
    late RavenElectrumClient client;
    setUp(() {
      server = MockElectrumServer();
      client = RavenElectrumClient(server.channel);
    });

    test('getBalance', () async {
      var method = 'blockchain.scripthash.get_balance';
      server.willRespondWith(method, {'confirmed': 1, 'unconfirmed': 0});
      var result = await client.getBalance('scripthash1');
      expect(result, ScripthashBalance(1, 0));
    });

    test('getHistory', () async {
      var method = 'blockchain.scripthash.get_history';
      server.willRespondWith(method, [
        {'height': 123, 'tx_hash': '00a1b2c3'},
        {'height': 124, 'tx_hash': '00010203'},
      ]);
      var results = await client.getHistory('scripthash1');
      expect(results, [
        ScripthashHistory(height: 123, txHash: '00a1b2c3'),
        ScripthashHistory(height: 124, txHash: '00010203')
      ]);
    });

    test('getUnspent', () async {
      var method = 'blockchain.scripthash.get_unspent';
      server.willRespondWith(
        method,
        [
          {'height': 123, 'tx_hash': '00a1b2c3', 'tx_pos': 1, 'value': 5}
        ],
      );
      var results = await client.getUnspent('scripthash1');
      expect(
        results,
        [
          ScripthashUnspent(
              scripthash: 'scripthash1',
              height: 123,
              txHash: '00a1b2c3',
              txPos: 1,
              value: 5)
        ],
      );
    });
  });
}
