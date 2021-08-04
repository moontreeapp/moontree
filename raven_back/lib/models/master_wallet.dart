import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:raven/wallets/hd_wallet.dart';
import 'package:ravencoin/ravencoin.dart';

import '../cipher.dart';
import '../records.dart' as records;
import '../records/net.dart';
import '../models.dart' as models;

class MasterWallet extends DerivedWallet {
  MasterWallet(seed, {net = Net.Test, cipher = const NoCipher()})
      : super(seed, net: net, cipher: cipher);

  factory MasterWallet.fromEncryptedSeed(encryptedSeed,
      {name = 'Wallet', net = Net.Test, cipher = const NoCipher()}) {
    return MasterWallet(cipher.decrypt(encryptedSeed),
        net: net, cipher: cipher);
  }

  factory MasterWallet.fromRecord(records.MasterWallet record,
      {cipher = const NoCipher()}) {
    return MasterWallet(cipher.decrypt(record.encryptedSeed),
        net: record.net, cipher: cipher);
  }

  records.MasterWallet toRecord() {
    return records.MasterWallet(encryptedSeed, net: net);
  }

  Uint8List get seed {
    return cipher.decrypt(encryptedSeed);
  }

  String get mnemonic {
    // fix
    return bip39.entropyToMnemonic(seed as String);
  }

  models.LeaderWallet deriveLeader(int hdIndex, records.NodeExposure exposure) {
    var wallet = deriveWallet(hdIndex, exposure);
    return models.LeaderWallet(wallet.seed);
  }
}
