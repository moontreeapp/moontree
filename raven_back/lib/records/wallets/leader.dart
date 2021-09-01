// dart run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven/records/address.dart';
import 'package:raven/records/wallets/wallet.dart';
import 'package:raven/records/net.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/utils/derivation_path.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;

import '../_type_id.dart';

part 'leader.g.dart';

@HiveType(typeId: TypeId.LeaderWallet)
class LeaderWallet extends Wallet {
  @HiveField(2)
  final Uint8List encryptedSeed;

  LeaderWallet({
    required id,
    required accountId,
    required this.encryptedSeed,
  }) : super(id: id, accountId: accountId);

  @override
  String toString() =>
      'LeaderWallet($id, $accountId, ${encryptedSeed.take(6).toList()})';

  @override
  String get kind => 'HD Wallet';

  Uint8List get seed {
    return cipher.decrypt(encryptedSeed);
  }

  HDWallet deriveWallet(
    Net net,
    int hdIndex, [
    exposure = NodeExposure.External,
  ]) {
    var seededWallet = HDWallet.fromSeed(seed, network: networks[net]!);
    return seededWallet
        .derivePath(getDerivationPath(hdIndex, exposure: exposure));
  }

  Address deriveAddress(
    Net net,
    int hdIndex,
    NodeExposure exposure,
  ) {
    var seededWallet = deriveWallet(net, hdIndex, exposure);
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: id,
        accountId: accountId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: net);
  }

  //String get mnemonic {
  //  // fix
  //  return bip39.entropyToMnemonic(seed as String);
  //}

}
