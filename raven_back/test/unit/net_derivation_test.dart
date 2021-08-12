// dart test test/unit/net_derivation_test.dart
import 'package:raven/records/wallets/leader.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/records/net.dart';

final seed = bip39.mnemonicToSeed(
    'smile build brain topple moon scrap area aim budget enjoy polar erosion');

void main() {
  test('derive mainnet', () {
    var wallet = LeaderWallet(seed: seed);
    var derived = wallet.deriveWallet(0, NodeExposure.Internal);
    var address = wallet.deriveAddress(0, NodeExposure.Internal);
    print(wallet.seededWallet.pubKey);
    print(derived.pubKey);
    print(address.address);
    print(address.scripthash);
    //expect(address.address, [4, 3, 2, 1]);
  });

  test('derive testnet', () {
    var wallet = LeaderWallet(seed: seed);
    var derived = wallet.deriveWallet(0, NodeExposure.Internal);
    var address = wallet.deriveAddress(0, NodeExposure.Internal);
    print(wallet.seededWallet.pubKey);
    print(derived.pubKey);
    print(address.address);
    print(address.scripthash);
  });
}
