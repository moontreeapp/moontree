import 'package:hive/hive.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/utils/enum.dart';
import 'package:ravencoin/ravencoin.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/records/cipher_update.dart';
import 'package:raven_back/security/cipher_base.dart';
import 'package:raven_back/security/encrypted_wif.dart';
import 'package:raven_back/utils/seed_wallet.dart';

import '../net.dart';
import '../_type_id.dart';
import 'wallet.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(3)
  final String encryptedWIF;

  SingleWallet({
    required String walletId,
    required String accountId,
    required this.encryptedWIF,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
  }) : super(
            walletId: walletId,
            accountId: accountId,
            cipherUpdate: cipherUpdate);

  @override
  List<Object?> get props => [walletId, accountId, cipherUpdate, encryptedWIF];

  @override
  String toString() =>
      'SingleWallet($walletId, $accountId, $encryptedWIF, $cipherUpdate)';

  @override
  String get encrypted => encryptedWIF;

  @override
  String secret(CipherBase cipher) => EncryptedWIF(encrypted, cipher).secret;

  @override
  KPWallet seedWallet(CipherBase cipher, {Net net = Net.Main}) =>
      SingleSelfWallet(secret(cipher)).wallet;

  @override
  SecretType get secretType => EncryptedWIF.secretType;

  @override
  WalletType get walletType => WalletType.single;

  @override
  String get secretTypeToString => describeEnum(secretType);

  @override
  String get walletTypeToString => describeEnum(walletType);
}
