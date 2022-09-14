import 'package:hive/hive.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/seed_wallet.dart';

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(7)
  final String encryptedWIF;

  SingleWallet({
    required String id,
    required this.encryptedWIF,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    bool skipHistory = false,
    String? name,
  }) : super(
          id: id,
          cipherUpdate: cipherUpdate,
          backedUp: true,
          skipHistory: skipHistory,
          name: name,
        );

  factory SingleWallet.from(
    SingleWallet existing, {
    String? id,
    String? encryptedWIF,
    CipherUpdate? cipherUpdate,
    bool? skipHistory,
    String? name,
  }) =>
      SingleWallet(
        id: id ?? existing.id,
        encryptedWIF: encryptedWIF ?? existing.encryptedWIF,
        cipherUpdate: cipherUpdate ?? existing.cipherUpdate,
        skipHistory: skipHistory ?? existing.skipHistory,
        name: name ?? existing.name,
      );

  @override
  List<Object?> get props => [id, cipherUpdate, encryptedWIF, skipHistory];

  @override
  String toString() =>
      'SingleWallet($id, $encryptedWIF, $cipherUpdate, $skipHistory)';

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

  String? get publicKey => services.wallet.single.getKPWallet(this).pubKey;
}
