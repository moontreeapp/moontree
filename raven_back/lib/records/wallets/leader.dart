// dart run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven/records/wallets/wallet.dart';

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

  Uint8List get seed {
    return cipher.decrypt(encryptedSeed);
  }

  //String get mnemonic {
  //  // fix
  //  return bip39.entropyToMnemonic(seed as String);
  //}

}
