// dart test test/unit/wallet_derivation_test.dart
import 'dart:typed_data';

//import 'package:ravencoin_back/records/wallets/leader.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:ravencoin_back/security/cipher_none.dart';
import 'package:ravencoin_back/security/encrypted_wif.dart';
import 'package:ravencoin_back/utilities/random.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:convert/convert.dart';

import 'package:ravencoin_back/records/net.dart' as raven_net;

final mnemonic =
    'smile build brain topple moon scrap area aim budget enjoy polar erosion';

final seed = bip39.mnemonicToSeed(mnemonic);
final entropy = bip39.mnemonicToEntropy(mnemonic);

// ignore: todo
// TODO: when we switch from CipherNone to CipherAES, we need to encrypt/decrypt
final encryptedSeed = seed;

KPWallet newKPWallet({
  required Uint8List privateKey,
  bool compressed = true,
}) {
  return KPWallet(
      ECPair.fromPrivateKey(
        privateKey,
        network: raven_net.networks[raven_net.Net.Test]!,
        compressed: compressed,
      ),
      P2PKH(
          data: PaymentData(),
          network: raven_net.networks[raven_net.Net.Test]!),
      raven_net.networks[raven_net.Net.Test]!);
}

void main() {
  //test('derive mainnet address', () {
  //  var wallet = LeaderWallet(
  //      walletId: '0', accountId: 'a1', encryptedSeed: encryptedSeed);
  //  var derived = wallet.deriveWallet(Net.Main, 0, NodeExposure.Internal);
  //  var address = wallet.deriveAddress(Net.Main, 0, NodeExposure.Internal);
  //  expect(derived.pubKey,
  //      '03cd88842308a57abb3a3b6dce56e7e33a9ceefdb92d1a23d1c102f4af7a1ca617');
  //  expect(derived.address, 'RBT3LwNAZN1fq5C3WQUkDX5wiE8qWgn7FR');
  //  expect(address.scripthash,
  //      'db281a3a6fb0a3ee5f2ccb41094b329e6d00a4207eeba496fa6ca888fccec9a0');
  //});
  //
  //test('derive testnet address', () {
  //  var wallet = LeaderWallet(
  //      walletId: '0', accountId: 'a1', encryptedSeed: encryptedSeed);
  //  var derived = wallet.deriveWallet(Net.Test, 0, NodeExposure.Internal);
  //  var address = wallet.deriveAddress(Net.Test, 0, NodeExposure.Internal);
  //  expect(derived.pubKey,
  //      '03cd88842308a57abb3a3b6dce56e7e33a9ceefdb92d1a23d1c102f4af7a1ca617');
  //  expect(derived.address, 'mhgoZUZrmZeMYBJTkoTzwuy4oxGwn96wVp');
  //  expect(address.scripthash,
  //      'db281a3a6fb0a3ee5f2ccb41094b329e6d00a4207eeba496fa6ca888fccec9a0');
  //});

  test('seed to mnemonic', () {
    // https://ravencoin.org/bip44/
    expect(hex.encode(seed),
        '10aec63e639df18c6411c3e82cbad807d9fad19163e59cd4da98ff5e9b8579093fd45b927af2cf1f7b78768025ed678650ef2d9e46db9df85d697e4b03940e1c');
    expect(
        bip39.entropyToMnemonic(bip39.mnemonicToEntropy(mnemonic)), mnemonic);
  });

  test('string to uin8list to string', () {
    var decoded = Uint8List.fromList(hex.decode(entropy));
    expect(hex.encode(decoded), entropy);
  });

  test('hdwallet public key', () {
    var testnet = HDWallet.fromSeed(seed,
        network: raven_net.networks[raven_net.Net.Test]!);
    var mainnet = HDWallet.fromSeed(seed,
        network: raven_net.networks[raven_net.Net.Main]!);
    expect(testnet.pubKey, mainnet.pubKey);
    expect(testnet.address == mainnet.address, false);
  });

  test('SingleWallet Key', () {
    //var privateKey =
    '3095cb26affefcaaa835ff968d60437c7c764da40cdd1a1b497406c7902a8ac9';
    var wif = 'Kxr9tQED9H44gCmp6HAdmemAzU3n84H3dGkuWTKvE23JgHMW8gct';
    //var wallet = SingleWallet(
    //    accountId: 'a1',
    //    encryptedPrivateKey:
    //        CipherNone().encrypt(Uint8List.fromList(hex.decode(privateKey))));
    //var wallet =
    //    newKPWallet(privateKey: Uint8List.fromList(hex.decode(privateKey)));
    //var wallet = SingleWallet.fromWIF(
    //    accountId: 'a1',
    //    encryptedPrivateKey:
    //        CipherNone().encrypt(Uint8List.fromList(hex.decode(privateKey))),
    //    wif: 'Kxr9tQED9H44gCmp6HAdmemAzU3n84H3dGkuWTKvE23JgHMW8gct');
    var ewif = EncryptedWIF.fromWIF(wif, CipherNone());
    var wallet = SingleWallet(
        id: ewif.walletId,
        cipherUpdate: CipherUpdate(CipherType.None),
        encryptedWIF: ewif.encryptedSecret);
    expect(wallet.encryptedWIF,
        '803095cb26affefcaaa835ff968d60437c7c764da40cdd1a1b497406c7902a8ac901');
  });

  test('generate random private key', () {
    //https://developer.bitcoin.org/devguide/wallets.html
    //var privateKey =
    //    '3095cb26affefcaaa835ff968d60437c7c764da40cdd1a1b497406c7902a8ac9';
    //
    //var wif = 'Kxr9tQED9H44gCmp6HAdmemAzU3n84H3dGkuWTKvE23JgHMW8gct';
    //0xFFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFE
    //  BAAE DCE6 AF48 A03B BFD2 5E8C D036 4140,
    var bytes = randomBytes(32);
    expect(bytes.length, 32);
    expect(hex.encode(bytes).length, 64);
  });
}
