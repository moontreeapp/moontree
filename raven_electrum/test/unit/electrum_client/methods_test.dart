import 'package:test/test.dart';

import 'package:raven_electrum_client/raven_electrum_client.dart';

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

    test('getTransaction', () async {
      var method = 'blockchain.transaction.get';
      server.willRespondWith(
        method,
        [
          {'height': 123, 'tx_hash': '00a1b2c3', 'tx_pos': 1, 'value': 5}
        ],
      );
      print('getting');
      var ret = await client.request('blockchain.transaction.get', [
        'b0ce422f7f827b856935062b39e4fa3bdb5470f96ae852dfeef85a18d13ad2a8',
        true
      ]);
      print(ret);

      var results = await client.getTransaction(
          'b0ce422f7f827b856935062b39e4fa3bdb5470f96ae852dfeef85a18d13ad2a8');
      print(results);
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
