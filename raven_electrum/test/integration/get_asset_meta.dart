// dart --sound-null-safety test test/integration/get_stats_test.dart --concurrency=1
import 'package:test/test.dart';
import 'package:raven_electrum/raven_electrum.dart';

void main() {
  group('electrum_client', () {
    test('get our asset meta and transaction (original owner)', () async {
      var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
      var meta = await client.getMeta('ZVZZT!');
      print(meta);
      expect(meta != null, true);
      var tx = await client.getTransaction(meta!.source.txHash);
      print(tx);
    });
    test('get our asset meta and transaction (original owner) MAIN', () async {
      var client = await RavenElectrumClient.connect('electrum1.rvn.rocks');
      var meta = await client.getMeta('PORKYPUNX/AIRDROP2');
      print(meta);
      expect(meta != null, true);
      var tx = await client.getTransaction(meta!.source.txHash); // ?? timesout
      print(tx);
    });
  });
}
