import 'package:hive/hive.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

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
    required String id,
    required this.encryptedWIF,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
  }) : super(id: id, cipherUpdate: cipherUpdate, name: name);

  @override
  List<Object?> get props => [id, cipherUpdate, encryptedWIF];

  @override
  String toString() => 'SingleWallet($id, $encryptedWIF, $cipherUpdate)';

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
  String get secretTypeToString => secretType.enumString;

  @override
  String get walletTypeToString => walletType.enumString;
}
