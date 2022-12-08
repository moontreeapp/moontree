// dart test test/unit/raven_tx_test.dart

import 'package:ravencoin_back/records/types/chain.dart';
import 'package:test/test.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show HDWallet, TransactionBuilder;

import 'package:ravencoin_back/records/types/net.dart' show Net;
import 'package:ravencoin_back/records/wallets/extended_wallet_base.dart';

void main() {
  group('Wallet Transaction', () {
    test('create & sign a 1-to-1 transaction', () async {
      var network = ChainNet(Chain.ravencoin, Net.test).network;

      var wallet = HDWallet.fromBase58(
          'tprv8jsr128yT1XaEVNpw7t4v5ijZBURTzvqFzy71Favkx7VnMYsmcAf'
          'KMkW8xQ8YJUwDe1NZE6cyU6NQmfeNQWbKrkdnZXEyPdqpKx6UVc1dNF',
          network: network);

      final txb = TransactionBuilder(network: network);
      txb.setVersion(1);
      txb.addInput(
          '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
          1); // previous transaction output, has 5000000 satoshis
      // print(txb.tx.virtualSize());
      txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
          4000000); // (in)5000000 - (out)4000000 = (fee)1000000, this is the miner fee
      // print(txb.tx.virtualSize());
      txb.sign(vin: 0, keyPair: wallet.keyPair);
      var transaction = txb.build().toHex();
      expect(
          transaction,
          '0100000001ae463c8cf936b87c6800f2b3982c451eb3a15f560789dca3337106'
          'b847c7fc56010000006b483045022100ad0421fa376357af3aa45e082be50505'
          '30a62c82f83130258d35fa106e4596c002204d2cd2c4eb781e2a065e7009188b'
          '7dba8e869aca2493b0265fff01656f7fc1ec012103911a855491fd016e6497d6'
          '5f16fc7a7d8c0cf14439f8069da7e313483ba0acddffffffff0100093d000000'
          '00001976a9145dbe75f408e8154364e2457a3ab413128e090e3588ac00000000');
    });
  });
}
