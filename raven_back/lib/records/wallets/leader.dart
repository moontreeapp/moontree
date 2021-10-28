import 'package:hive/hive.dart';
import 'package:raven/raven.dart';
import 'package:raven/services/wallet/constants.dart';
import 'package:raven/utils/enum.dart';
import 'package:raven/utils/seed_wallet.dart';
import 'package:ravencoin/ravencoin.dart';

import '../_type_id.dart';

part 'leader.g.dart';

@HiveType(typeId: TypeId.LeaderWallet)
class LeaderWallet extends Wallet {
  @HiveField(3)
  final String encryptedEntropy;

  LeaderWallet({
    required String walletId,
    required String accountId,
    required this.encryptedEntropy,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
  }) : super(
            walletId: walletId,
            accountId: accountId,
            cipherUpdate: cipherUpdate);

  @override
  List<Object?> get props =>
      [walletId, accountId, cipherUpdate, encryptedEntropy];

  @override
  String toString() =>
      'LeaderWallet($walletId, $accountId, $encryptedEntropy, $cipherUpdate)';

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
  String get secretTypeToString => describeEnum(secretType);

  @override
  String get walletTypeToString => describeEnum(walletType);
}
