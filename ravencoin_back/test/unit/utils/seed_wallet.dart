// dart test test/unit/utils/seed_wallet.dart
import 'dart:typed_data';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_back/utilities/seed_wallet.dart';

void main() {
  test('SingleSelfWallet', () {
    const String wif = 'Kxr9tQED9H44gCmp6HAdmemAzU3n84H3dGkuWTKvE23JgHMW8gct';
    final SingleSelfWallet singleSelfWallet = SingleSelfWallet(wif);
    const String privateKey =
        '3095cb26affefcaaa835ff968d60437c7c764da40cdd1a1b497406c7902a8ac9';
    expect(singleSelfWallet.wallet.privKey, privateKey);
  });

  test('SeedWallet', () {
    const String mnemonic =
        'smile build brain topple moon scrap area aim budget enjoy polar erosion';
    final Uint8List seed = bip39.mnemonicToSeed(mnemonic);
    final SeedWallet seedWallet = SeedWallet(seed, Chain.ravencoin, Net.test);
    const String privateKey =
        'b3c6d3e13b383424704b0a3419815f49b31dc9e049c7020f2eeb36e5a36d1a6e';
    expect(seedWallet.wallet.privKey, privateKey);
    expect(seedWallet.wallet.seed, seedWallet.seed);
  });
}
