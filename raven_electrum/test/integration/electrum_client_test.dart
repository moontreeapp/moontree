import 'package:test/test.dart';

import 'package:raven_electrum/raven_electrum.dart';

void main() {
  group('electrum_client', () {
    late RavenElectrumClient client;
    setUp(() async {
      // Our mainnet server:
      // var channel = await connect('143.198.142.78', port: 50002);

      // Our testnet server:
      // var channel = await connect('143.198.142.78', port: 50012);

      // Raven Foundation testnet server:
      // var channel = await connect('168.119.100.140', port: 50012);

      // HyperPeek's testnet server:
      var channel = await connect('testnet.rvn.rocks', port: 50002);
      //var channel = await connect('mainnet.rvn.rocks', port: 50002);

      client = RavenElectrumClient(channel);
    });

    test('get unspent', () async {
      var scripthash =
          'b3bbdf50410b85299f914d2c573a7cadc2133d8e6cc088dc400dd174937f86e1';
      var utxos = await client.getUnspent(scripthash);
      expect(utxos, [
        ScripthashUnspent(
            scripthash: scripthash,
            txHash:
                '84ab4db04a5d32fc81025db3944e6534c4c201fcc93749da6d1e5ecf98355533',
            txPos: 1,
            height: 765913,
            value: 5000087912000)
      ]);
    });

    test('withBatch', () async {
      var scripthash =
          '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';

      var futures = <Future>[];
      client.peer.withBatch(() {
        futures.add(client.getHistory(scripthash));
        futures.add(client.features());
      });
      var results = await Future.wait(futures);

      var features = results[1];
      expect(features['genesis_hash'],
          '000000ecfc5e6324a079542221d00e10362bdc894d56500c414060eea8a3ad5a');

      var history = results[0];
      expect(history, [
        ScripthashHistory(
            txHash:
                '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
            height: 747308),
        ScripthashHistory(
            txHash:
                '2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5',
            height: 769767)
      ]);
    });

    test('subscribes to scripthash', () async {
      var scripthash =
          '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';
      var stream = await client.subscribeScripthash(scripthash);
      var result = await stream.first;
      expect(result,
          '615dd2dec158d531d2875cee60c37e9e72f264d221a267a9ab512e0741ba4eb4');
    });

    test('get transaction', () async {
      //var ret = await client.request('blockchain.transaction.get', [
      //  'a66d891a144bdb00610c31655d7c6046b70700a4dcc2964430cbd49348f05948',
      //  true
      //]);
      //print(ret);
      var results = await client.getTransaction(
          'e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a');
      expect(results.toString(),
          'Transaction(txid: e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a, hash: ccabf8580cc55890cba647960bf52760f37caf1923b2f184198e424fd356e3d2, blockhash: 00000000e2ba484f128e5fff2d767f2d55d035a3d5e797081673c6f8886e58d9, blocktime: 1633390166, confirmations: ${results.confirmations}, height: 918159, hex: 020000000001010000000000000000000000000000000000000000000000000000000000000000ffffffff05038f020e00ffffffff020088526a740000001976a914713c2fa8992630a215bc6668822b0acfbc90ead988ac0000000000000000266a24aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf90120000000000000000000000000000000000000000000000000000000000000000000000000, locktime: 0, size: 173, vsize: 146, time: 1633390166, txid: e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a, version: 2, vin: [TxVin(038f020e00, 4294967295, null, null, null)], vout: [TxVout(5000.0, 0, 500000000000, TxScriptPubKey(OP_DUP OP_HASH160 713c2fa8992630a215bc6668822b0acfbc90ead9 OP_EQUALVERIFY OP_CHECKSIG, 76a914713c2fa8992630a215bc6668822b0acfbc90ead988ac, pubkeyhash, 1, [mqqgkYDUkLRLMPvHKhDSjyuwyeNqZhfzVc])), TxVout(0.0, 1, 0, TxScriptPubKey(OP_RETURN aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9, 6a24aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9, nulldata, null, null))])');
    });
    test('get memo', () async {
      var results = await client.getMemo(
          'e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a');
      expect(results.toString(),
          'aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9');
    });
  });
}
