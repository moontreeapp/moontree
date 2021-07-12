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

    test('subscribeHeaders', () async {
      var method = 'blockchain.headers.subscribe';
      server.willRespondWith(method, {'hex': '01', 'height': 788191});
      server.willNotifyWith(method, [
        {'hex': '02', 'height': 788192}
      ]);
      var results = await client.subscribeHeaders().take(2).toList();
      expect(results.length, 2);
      expect(results[0], BlockHeader('01', 788191));
      expect(results[1], BlockHeader('02', 788192));
    });

    test('subscribeAsset', () async {
      var method = 'blockchain.asset.subscribe';
      server.willRespondWith(method, 'status01');
      server.willNotifyWith(method, ['token', 'status02']);
      var results = await client.subscribeAsset('token').take(2).toList();
      expect(results.length, 2);
      expect(results[0], 'status01');
      expect(results[1], 'status02');
    });

    test('subscribeScripthash', () async {
      var method = 'blockchain.scripthash.subscribe';
      server.willRespondWith(method, 'status01');
      server.willNotifyWith(method, ['01', 'status02']);
      var results = await client.subscribeScripthash('01').take(2).toList();
      expect(results.length, 2);
      expect(results[0], 'status01');
      expect(results[1], 'status02');
    });
  });
}
