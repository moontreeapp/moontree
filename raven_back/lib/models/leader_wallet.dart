import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:raven/records/node_exposure.dart';
import 'package:raven/utils/derivation_path.dart';
import 'package:raven/models/wallet.dart' show Wallet;
import 'package:ravencoin/ravencoin.dart' as ravencoin;

import '../utils/cipher.dart';
import '../records.dart' as records;
import '../records/net.dart';
import '../models.dart' as models;

extension Scripthash on ravencoin.HDWallet {
  Uint8List get outputScript {
    return ravencoin.Address.addressToOutputScript(address!, network)!;
  }

  String get scripthash {
    var digest = sha256.convert(outputScript);
    var hash = digest.bytes.reversed.toList();
    return hex.encode(hash);
  }

  ravencoin.ECPair get keyPair {
    return ravencoin.ECPair.fromWIF(wif!,
        networks: ravencoin.ravencoinNetworks);
  }
}

const DEFAULT_CIPHER = NoCipher();

class LeaderWallet extends Wallet {
  // final int leaderWalletIndex;
  final Uint8List encryptedSeed;
  late final ravencoin.HDWallet seededWallet;
  late final bool isDerived;
  late final String id;
  late final String accountId;

  LeaderWallet(
      {required seed,
      accountId = 'primary',
      net = Net.Test,
      cipher = const NoCipher(),
      isDerived = false})
      : encryptedSeed = cipher.encrypt(seed),
        super(net: net, cipher: cipher) {
    seededWallet = ravencoin.HDWallet.fromSeed(seed, network: network);
    id = seededWallet.address!;
  }

  @override
  List<Object?> get props => [id];

  factory LeaderWallet.fromEncryptedSeed(encryptedSeed,
      {accountId = 'primary', net = Net.Test, cipher = const NoCipher()}) {
    return LeaderWallet(
        seed: cipher.decrypt(encryptedSeed), net: net, cipher: cipher);
  }

  factory LeaderWallet.fromRecord(records.Wallet record,
      {cipher = const NoCipher()}) {
    return LeaderWallet(
        seed: cipher.decrypt(record.encrypted),
        accountId: record.accountId,
        net: record.net,
        cipher: cipher);
  }

  records.Wallet toRecord() {
    return records.Wallet(
        accountId: accountId, isHD: true, encrypted: encryptedSeed, net: net);
  }

  //// getters /////////////////////////////////////////////////////////////////

  Uint8List get seed {
    return cipher.decrypt(encryptedSeed);
  }

  //String get mnemonic {
  //  // fix
  //  return bip39.entropyToMnemonic(seed as String);
  //}

  //int get balance => get all my addresses and sum balance (use service)

  //// Derive Wallet ///////////////////////////////////////////////////////////

  ravencoin.HDWallet deriveWallet(int hdIndex,
      [exposure = NodeExposure.External]) {
    return seededWallet.derivePath(getDerivationPath(hdIndex,
        exposure: exposure,
        leaderWalletIndex: 0 // needs to pass it's own index.
        ));
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

  models.LeaderWallet deriveLeader(int hdIndex, records.NodeExposure exposure) {
    var wallet = deriveWallet(hdIndex, exposure);
    return models.LeaderWallet(seed: wallet.seed, net: net, cipher: cipher);
  }
}
