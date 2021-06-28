import 'package:test/test.dart';
import 'package:raven/electrum_client/base_client.dart';

import './mock_electrum_server.dart';

void main() {
  late MockElectrumServer server;
  setUp(() => server = MockElectrumServer());

  group('BaseClient', () {
    var client;
    setUp(() => client = BaseClient(server.channel));

    test('makes a request', () async {
      server.willRespondWith('test', 'hello world');
      expect(await client.request('test'), 'hello world');
    });

    test('makes two requests', () async {
      server.willRespondWith('test', 'one');
      expect(await client.request('test'), 'one');

      server.willRespondWith('test', 'two');
      expect(await client.request('test'), 'two');
    });
  });
}
