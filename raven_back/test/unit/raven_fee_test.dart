// dart --no-sound-null-safety test test/unit/raven_fee_test.dart
import 'package:test/test.dart';
import 'package:ravencoin/ravencoin.dart';
import 'package:raven/fee.dart';

void main() {
  test('totalFeeByBytes', () async {
    final txb = TransactionBuilder(network: testnet);
    txb.setVersion(1);
    txb.addInput(
        '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae', 1);
    txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7', 4000000);
    var fee = totalFeeByBytes(txb);
    expect(fee, (txb.tx!.virtualSize() * .9765625).ceil());
    fee = totalFeeByBytes(txb, 'cheap');
    expect(fee, (txb.tx!.virtualSize() * .9765625 * 0.9).ceil());
    fee = totalFeeByBytes(txb, 'fast');
    expect(fee, (txb.tx!.virtualSize() * .9765625 * 1.1).ceil());
    expect(fee > 0, true);
  });
}
