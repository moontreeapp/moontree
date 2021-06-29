import 'package:raven/electrum_client/connect.dart';
import 'package:test/test.dart';
import 'package:raven/electrum_client/client/base_client.dart';

void main() {
  group('BaseClient', () {
    test('connects', () async {
      var channel = await connect('testnet.rvn.rocks');
      // var channel = await connect('143.198.142.78');
      var client = BaseClient(channel);
      var response = await client.request('server.features');
      expect(response['genesis_hash'],
          '000000ecfc5e6324a079542221d00e10362bdc894d56500c414060eea8a3ad5a');
    });
  });
}
