// dart run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'wallet.dart';

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(2)
  final Uint8List encryptedPrivateKey;

  SingleWallet({
    required id,
    required accountId,
    required this.encryptedPrivateKey,
  }) : super(id: id, accountId: accountId);

  @override
  String toString() =>
      'SingleWallet($id, $accountId, ${encryptedPrivateKey.take(6).toList()})';

  @override
  String get kind => 'Private Key Wallet';

  @override
  String get secret => privateKey.toString();

  Uint8List get privateKey {
    return cipher.decrypt(encryptedPrivateKey);
  }

  //String get mnemonic {
  //  // fix
  //  return bip39.entropyToMnemonic(seed as String);
  //}
}
