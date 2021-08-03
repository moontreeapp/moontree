/// DerivedWallet is derived as a child wallet from the Master seed

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:raven/cipher.dart';
import 'package:raven/records.dart' show Net;
import 'package:raven/records/node_exposure.dart';
import 'package:raven/utils/derivation_path.dart';
import 'package:raven/wallets/wallet.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;

class DerivedWallet extends Wallet {
  final Uint8List encryptedSeed;
  late final String id;
  late final HDWallet seededWallet;
  late final Cipher cipher;

  @override
  List<Object?> get props => encryptedSeed;

  DerivedWallet(seed, {net = Net.Test, this.cipher = const NoCipher()})
      : id = sha256.convert(seed).toString(),
        encryptedSeed = cipher.encrypt(seed),
        super(net: net) {
    seededWallet = HDWallet.fromSeed(seed, network: network);
  }

  factory DerivedWallet.fromEncryptedSeed(encryptedSeed,
      {net = Net.Test, cipher = const NoCipher()}) {
    return DerivedWallet(cipher.decrypt(encryptedSeed),
        net: net, cipher: cipher);
  }

  @override
  String toString() {
    return 'DerivedWallet($id)';
  }

  HDWallet deriveWallet(int hdIndex, [exposure = NodeExposure.External]) {
    return seededWallet.derivePath(
        getDerivationPath(hdIndex, exposure: exposure, wif: network.wif));
  }
}
