import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' as ravencoin;
import 'package:raven/utils/cipher.dart';
import 'package:raven/utils/derivation_path.dart';
import 'package:raven/models.dart' as models;
import 'package:raven/models/wallet.dart';
import 'package:raven/records.dart' as records;
import 'package:raven/records/net.dart';
import 'package:raven/records/node_exposure.dart';

export './wallet.dart';

const DEFAULT_CIPHER = NoCipher();

class LeaderWallet extends Wallet {
  final Uint8List encryptedSeed;
  final int leaderWalletIndex;
  late final ravencoin.HDWallet seededWallet;
  late final bool isDerived;
  late final String id;
  late final String accountId;

  LeaderWallet(
      {required seed,
      required this.leaderWalletIndex,
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

  factory LeaderWallet.fromEncryptedSeed(
      {required encryptedSeed,
      required leaderWalletIndex,
      accountId = 'primary',
      net = Net.Test,
      cipher = const NoCipher()}) {
    return LeaderWallet(
        seed: cipher.decrypt(encryptedSeed),
        leaderWalletIndex: leaderWalletIndex,
        net: net,
        cipher: cipher);
  }

  factory LeaderWallet.fromRecord(records.Wallet record,
      {cipher = const NoCipher()}) {
    return LeaderWallet(
        seed: cipher.decrypt(record.encrypted),
        leaderWalletIndex: record.leaderWalletIndex,
        accountId: record.accountId,
        net: record.net,
        cipher: cipher);
  }

  records.Wallet toRecord() {
    return records.Wallet(
        accountId: accountId,
        isHD: true,
        encrypted: encryptedSeed,
        net: net,
        leaderWalletIndex: leaderWalletIndex);
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
    return seededWallet
        .derivePath(getDerivationPath(hdIndex, exposure: exposure));
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

  models.LeaderWallet deriveNextLeader(String accountId) {
    var index = 0; // get wallets.leaderwallets.size
    return models.LeaderWallet(
        seed: seededWallet.derivePath(getDerivationPathForLeader(index)),
        leaderWalletIndex: index,
        accountId: accountId,
        net: net,
        cipher: cipher);
  }
}
