import 'package:test/test.dart';
import 'package:raven_electrum/raven_electrum.dart';

void main() {
  group('subscriptions', () {
    late RavenElectrumClient client;
    setUp(() async {
      client =
          await RavenElectrumClient.connect('testnet.rvn.rocks', port: 50002);
    });

    test('getMeta', () async {
      var results = await client.getMeta('MOONTREE');
      expect(
        results,
        AssetMeta(
            symbol: 'MOONTREE',
            satsInCirculation: 100000000000000,
            divisions: 0,
            reissuable: 1,
            hasIpfs: 1,
            source: TxSource(
                txHash:
                    '4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240',
                txPos: 3,
                height: 969691)),
      );
    });
    test('getRelayFee', () async {
      var results = await client.getRelayFee();
      expect(results, 0.01);
    });
    test('getEstimateFee', () async {
      var results = await client.getFeeEstimate(100);
      expect(results > 0.01, true);
    });
  });
}
