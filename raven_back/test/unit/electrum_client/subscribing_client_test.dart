import 'package:test/test.dart';
import 'package:raven/electrum_client/client/subscribing_client.dart';

import './mock_electrum_server.dart';

void main() {
  late MockElectrumServer server;
  setUp(() => server = MockElectrumServer());

  group('SubscribingClient', () {
    // ignore: unused_local_variable
    late SubscribingClient client;
    setUp(() => client = SubscribingClient(server.channel));

    test('subscribes (without params)', () {
      server.notifyClient('test', {'one': 2});
    });
  });
}
