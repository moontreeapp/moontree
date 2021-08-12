// dart run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven/records/wallets/wallet.dart';

part 'leader.g.dart';

@HiveType(typeId: 0)
class LeaderWallet extends Wallet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Uint8List encryptedSeed;

  @HiveField(2)
  final String accountId;

  LeaderWallet(
      {required this.id, required this.encryptedSeed, required this.accountId});

  @override
  List<Object?> get props => [id];

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
