import 'package:hive/hive.dart';
import 'package:raven/raven.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/security/cipher.dart';
import 'package:raven/security/encrypted_wif.dart';
import 'package:raven/utils/seed_wallet.dart';
import 'package:ravencoin/ravencoin.dart';
import '../net.dart';
import 'wallet.dart';

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(3)
  final String encryptedWIF;

  SingleWallet({
    required String walletId,
    required String accountId,
    required this.encryptedWIF,
    required CipherUpdate cipherUpdate,
  }) : super(
            walletId: walletId,
            accountId: accountId,
            cipherUpdate: cipherUpdate);

  @override
  String toString() =>
      'SingleWallet($walletId, $accountId, $encryptedWIF, $cipherUpdate)';

  @override
  String get encrypted => encryptedWIF;

  @override
  String secret(Cipher cipher) => EncryptedWIF(encrypted, cipher).secret;

  @override
  KPWallet seedWallet(Cipher cipher, {Net net = Net.Main}) =>
      SingleSelfWallet(secret(cipher)).wallet;

  @override
  String get humanType => Lingo.english[humanTypeKey]!;

  @override
  String get humanSecretType => Lingo.english[humanSecretTypeKey]!;

  @override
  LingoKey get humanTypeKey => LingoKey.singleWalletType;

  @override
  LingoKey get humanSecretTypeKey => LingoKey.singleWalletSecretType;
}
