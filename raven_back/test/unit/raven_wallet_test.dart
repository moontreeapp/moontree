// dart test test/unit/raven_wallet_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/records/net.dart';
import 'package:raven/models/account.dart';

final seed = bip39.mnemonicToSeed(
    'smile build brain topple moon scrap area aim budget enjoy polar erosion');

final account = Account(seed, net: Net.Test);

void main() {
  test('reverse', () {
    var sample = [1, 2, 3, 4];
    expect(sample.reversed.toList(), [4, 3, 2, 1]);
  });

  test('scripthash', () {
    expect(account.deriveWallet(0).scripthash,
        '45520ecd53be9412d82e904a12a8fe7aeb0251eea1eaf1be02cab9fb98d1fad7');
  });
}
