// dart --no-sound-null-safety test test/unit/raven_fee_test.dart
import 'package:test/test.dart';
import 'package:ravencoin/ravencoin.dart';
import 'package:raven/services/transaction/fee.dart';

void main() {
  test('totalFeeByBytes', () {
    final txb = TransactionBuilder(network: testnet);
    txb.setVersion(1);
    txb.addInput(
        '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae', 1);
    txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7', 4000000);
    var tx = txb.tx!;
    var fee = tx.fee();
    expect(fee, 93500);
    fee = tx.fee(cheap);
    expect(fee, 85000);
    fee = tx.fee(fast);
    expect(fee, 127500);
  });

  test('min fee is 0.01 RVN per 1000 bytes', () {
    expect(calculateFee(1, standard), 1100);
    expect(calculateFee(1, cheap), 1000);
    expect(calculateFee(1, fast), 1500);
  });

  test('standard fee is 1000 sats per vsize', () {
    expect(calculateFee(2000, standard), 2200000);
  });
}
