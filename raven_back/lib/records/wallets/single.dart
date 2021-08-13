// dart run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven/records/wallets/wallet.dart';

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Uint8List encryptedPrivateKey;

  @HiveField(2)
  final String accountId;

  SingleWallet({
    required this.id,
    required this.encryptedPrivateKey,
    required this.accountId,
  });

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'SingleWallet($id, $accountId, ${encryptedPrivateKey.take(6).toList()})';

  Uint8List get privateKey {
    return cipher.decrypt(encryptedPrivateKey);
  }

  //String get mnemonic {
  //  // fix
  //  return bip39.entropyToMnemonic(seed as String);
  //}
}
