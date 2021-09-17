// dart run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven/records/address.dart';
import 'package:raven/records/wallets/wallet.dart';
import 'package:raven/records/net.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/utils/cipher.dart';
import 'package:raven/utils/derivation_path.dart';
import 'package:raven/utils/hex.dart' as hex;
import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;

import '../_type_id.dart';
import '../cipher_type.dart';

part 'leader.g.dart';

@HiveType(typeId: TypeId.LeaderWallet)
class LeaderWallet extends Wallet {
  @HiveField(3)
  final String encryptedEntropy;

  LeaderWallet({
    required String walletId,
    required accountId,
    required this.encryptedEntropy,
  }) : super(walletId: walletId, accountId: accountId);

  @override
  String toString() => 'LeaderWallet($walletId, $accountId, $encryptedEntropy)';

  @override
  String get kind => 'HD Wallet';

  // @override
  // String get secret => mnemonic;

  // static Uint8List getSeed(String mnemonic) => bip39.mnemonicToSeed(mnemonic);
  // Uint8List get seed => getSeed(mnemonic);

  // static String getMnemonic(String entropy) => bip39.entropyToMnemonic(entropy);
  // String get mnemonic => getMnemonic(entropy);

  // static String getEntropy(String encryptedEntropy) =>
  //     hex.encode(AESCipher(password).decrypt(hex.decode(encryptedEntropy)));
  // String get entropy => getEntropy(encryptedEntropy);

  // ///String get wif => ///;

  // /// this requires that we either do not allow testnet for users or
  // /// on import of wallet move from account if wallet exists and
  // /// is in an account associated with a different network (testnet vs mainnet)
  // static String deriveWalletId(String encryptedEntropy) =>
  //     HDWallet.fromSeed(getSeed(getMnemonic(getEntropy(encryptedEntropy))))
  //         .pubKey;

  // HDWallet deriveSeedWallet(Net net) =>
  //     HDWallet.fromSeed(seed, network: networks[net]!);

  // HDWallet deriveWallet(
  //   Net net,
  //   int hdIndex, [
  //   exposure = NodeExposure.External,
  // ]) =>
  //     deriveSeedWallet(net)
  //         .derivePath(getDerivationPath(hdIndex, exposure: exposure));

  // Address deriveAddress(
  //   Net net,
  //   int hdIndex,
  //   NodeExposure exposure,
  // ) {
  //   var seededWallet = deriveWallet(net, hdIndex, exposure);
  //   return Address(
  //       scripthash: seededWallet.scripthash,
  //       address: seededWallet.address!,
  //       walletId: walletId,
  //       hdIndex: hdIndex,
  //       exposure: exposure,
  //       net: net);
  // }

  static String encryptEntropy(String entropy) =>
      hex.encode(NoCipher().encrypt(hex.decode(entropy)));
}
