/// the PrivateKeyWallet is an imported wallet

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:raven/cipher.dart';
import 'package:raven/wallets/wallet.dart';
import 'package:raven/records.dart' show Net;

class PrivateKeyWallet extends Wallet {
  final Uint8List encryptedPrivateKey;
  late final String id;
  late final Cipher cipher;

  @override
  List<Object?> get props => encryptedPrivateKey;

  PrivateKeyWallet(privateKey, {net = Net.Test, this.cipher = const NoCipher()})
      : id = sha256.convert(privateKey).toString(),
        encryptedPrivateKey = cipher.encrypt(privateKey);

  factory PrivateKeyWallet.fromEncryptedPrivateKey(encryptedPrivateKey,
      {net = Net.Test, cipher = const NoCipher()}) {
    return PrivateKeyWallet(cipher.decrypt(encryptedPrivateKey),
        net: net, cipher: cipher);
  }

  @override
  String toString() {
    return 'PrivateKeyWallet($id)';
  }
}
