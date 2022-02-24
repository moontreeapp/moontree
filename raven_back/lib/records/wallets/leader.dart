import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/utils/seed_wallet.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

import '../_type_id.dart';

part 'leader.g.dart';

@HiveType(typeId: TypeId.LeaderWallet)
class LeaderWallet extends Wallet {
  @HiveField(3)
  final String encryptedEntropy;

  LeaderWallet({
    required String walletId,
    required this.encryptedEntropy,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
  }) : super(walletId: walletId, cipherUpdate: cipherUpdate, name: name);

  @override
  List<Object?> get props => [walletId, cipherUpdate, encryptedEntropy];

  @override
  String toString() =>
      'LeaderWallet($walletId,  $encryptedEntropy, $cipherUpdate)';

  @override
  String get encrypted => encryptedEntropy;

  @override
  String secret(CipherBase cipher) =>
      EncryptedEntropy(encrypted, cipher).secret;

  @override
  HDWallet seedWallet(CipherBase cipher, {Net net = Net.Main}) => SeedWallet(
        EncryptedEntropy(encrypted, cipher).seed,
        net,
      ).wallet;

  @override
  SecretType get secretType => EncryptedEntropy.secretType;

  @override
  WalletType get walletType => WalletType.leader;

  @override
  String get secretTypeToString => secretType.enumString;

  @override
  String get walletTypeToString => walletType.enumString;
}
