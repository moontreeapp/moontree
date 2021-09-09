// dart test test/unit/net_derivation_test.dart
import 'package:raven/records/wallets/leader.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/records/net.dart';

final seed = bip39.mnemonicToSeed(
    'smile build brain topple moon scrap area aim budget enjoy polar erosion');

// TODO: when we switch from NoCipher to AESCipher, we need to encrypt/decrypt
final encryptedSeed = seed;

void main() {
  test('derive mainnet address', () {
    var wallet = LeaderWallet(
        walletId: '0', accountId: 'a1', encryptedSeed: encryptedSeed);
    var derived = wallet.deriveWallet(Net.Main, 0, NodeExposure.Internal);
    var address = wallet.deriveAddress(Net.Main, 0, NodeExposure.Internal);
    expect(derived.pubKey,
        '03cd88842308a57abb3a3b6dce56e7e33a9ceefdb92d1a23d1c102f4af7a1ca617');
    expect(derived.address, 'RBT3LwNAZN1fq5C3WQUkDX5wiE8qWgn7FR');
    expect(address.scripthash,
        'db281a3a6fb0a3ee5f2ccb41094b329e6d00a4207eeba496fa6ca888fccec9a0');
  });

  test('derive testnet address', () {
    var wallet = LeaderWallet(
        walletId: '0', accountId: 'a1', encryptedSeed: encryptedSeed);
    var derived = wallet.deriveWallet(Net.Test, 0, NodeExposure.Internal);
    var address = wallet.deriveAddress(Net.Test, 0, NodeExposure.Internal);
    expect(derived.pubKey,
        '03cd88842308a57abb3a3b6dce56e7e33a9ceefdb92d1a23d1c102f4af7a1ca617');
    expect(derived.address, 'mhgoZUZrmZeMYBJTkoTzwuy4oxGwn96wVp');
    expect(address.scripthash,
        'db281a3a6fb0a3ee5f2ccb41094b329e6d00a4207eeba496fa6ca888fccec9a0');
  });
}
