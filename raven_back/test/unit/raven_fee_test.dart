// dart --no-sound-null-safety test test/unit/raven_tx_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven/fee.dart';

void main() {
  test('totalFeeByBytes', () async {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var account = Account(ravencoinTestnet, seed: seed);
    var node = account.node(4, exposure: NodeExposure.Internal);
    final txb = TransactionBuilder(network: node.params.network);
    txb.setVersion(1);
    txb.addInput(
        '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae', 1);
    txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7', 4000000);
    var fee = totalFeeByBytes(txb);
    expect(fee, (txb.tx.virtualSize() * .9765625).ceil());
    fee = totalFeeByBytes(txb, 'cheap');
    expect(fee, (txb.tx.virtualSize() * .9765625 * 0.9).ceil());
    fee = totalFeeByBytes(txb, 'fast');
    expect(fee, (txb.tx.virtualSize() * .9765625 * 1.1).ceil());
    expect(fee > 0, true);
  });
}
