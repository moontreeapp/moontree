import 'package:test/test.dart';
import 'package:raven_electrum_client/client/subscribing_client.dart';

import './mock_electrum_server.dart';

void main() {
  group('SubscribingClient', () {
    late MockElectrumServer server;
    late SubscribingClient client;
    setUp(() {
      server = MockElectrumServer();
      client = SubscribingClient(server.channel);
    });

    test('subscribes (without params)', () async {
      var method = 'blockchain.headers.subscribe';
      server.willRespondWith(method, {'hex': '01', 'height': 788191});
      server.willNotifyWith(method, [
        {'hex': '02', 'height': 788192}
      ]);
      registerSubscribable('blockchain.headers', 0);
      var results =
          await client.subscribe('blockchain.headers').take(2).toList();
      expect(results.length, 2);
      expect(results[0], {'hex': '01', 'height': 788191});
      expect(results[1], {'hex': '02', 'height': 788192});
    });
  });
}
