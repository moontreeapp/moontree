import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart';

import 'package:raven/records/node_exposure.dart';
import 'package:raven/models/wallet.dart';

import '../utils/cipher.dart';
import '../records.dart' as records;
import '../records/net.dart';
import '../models.dart' as models;

class SingleWallet extends Wallet {
  final Uint8List encryptedPrivateKey;
  late final KPWallet seededWallet;
  late final String id;
  late final String accountId;

  SingleWallet(
      {required Uint8List privateKey,
      accountId = 'primary',
      net = Net.Test,
      cipher = const NoCipher()})
      : encryptedPrivateKey = cipher.encrypt(privateKey),
        super(net: net, cipher: cipher) {
    seededWallet = KPWallet(
        ECPair.fromPrivateKey(privateKey, network: network, compressed: true),
        P2PKH(data: PaymentData(), network: network),
        network);
    id = seededWallet.address!;
  }

  @override
  List<Object?> get props => [id];

  factory SingleWallet.fromEncryptedPrivateKey(encryptedPrivateKey,
      {accountId = 'primary', net = Net.Test, cipher = const NoCipher()}) {
    return SingleWallet(
        privateKey: cipher.decrypt(encryptedPrivateKey),
        net: net,
        cipher: cipher);
  }

  factory SingleWallet.fromRecord(records.Wallet record,
      {cipher = const NoCipher()}) {
    return SingleWallet(
        privateKey: cipher.decrypt(record.encrypted),
        accountId: record.accountId,
        net: record.net,
        cipher: cipher);
  }

  records.Wallet toRecord() {
    return records.Wallet(
        accountId: accountId,
        isHD: true,
        encrypted: encryptedPrivateKey,
        net: net);
  }

  //// getters /////////////////////////////////////////////////////////////////

  Uint8List get privateKey {
    return cipher.decrypt(encryptedPrivateKey);
  }

  //String get mnemonic {
  //  // fix
  //  return bip39.entropyToMnemonic(seed as String);
  //}

  //int get balance => get all my addresses and sum balance (use service)

  //// Derive Wallet ///////////////////////////////////////////////////////////

  KPWallet deriveWallet(int hdIndex, [exposure = NodeExposure.External]) {
    return seededWallet;
  }

  models.Address deriveAddress(int hdIndex, records.NodeExposure exposure) {
    var wallet = deriveWallet(hdIndex, exposure);
    return models.Address(
        scripthash: wallet.scripthash,
        address: wallet.address!,
        walletId: id,
        accountId: accountId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: net);
  }

  //// Sending Functionality ///////////////////////////////////////////////////
}
