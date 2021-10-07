// dart --sound-null-safety test test/integration/get_stats_test.dart --concurrency=1
import 'package:test/test.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

void main() {
  group('electrum_client', () {
    test('get our asset addresses', () async {
      //var client = await RavenElectrumClient.connect('rvn4lyfe.com'); // mainnet
      var client =
          await RavenElectrumClient.connect('electrum1.rvn.rocks'); // mainnet
      var addresses = await client.getAddresses('CATE');
      print(addresses);
      expect(addresses!.owner, '');
      addresses = await client.getAddresses('CATE!');
      print(addresses);
      // will fail if CATE! changes ownership...
      expect(addresses!.owner, 'RWaahojLNr4VCQ8j9hwndqfA1UuzN3tanW');
      //AssetAddresses(assetCountByAddress: {RWaahojLNr4VCQ8j9hwndqfA1UuzN3tanW: 1})
    });
  });
}
