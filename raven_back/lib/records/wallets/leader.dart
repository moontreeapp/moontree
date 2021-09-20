import 'package:hive/hive.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/records/wallets/wallet.dart';
import 'package:raven/security/cipher.dart';
import 'package:raven/security/encrypted_entropy.dart';
import 'package:raven/utils/seed_wallet.dart';
import 'package:ravencoin/ravencoin.dart';

import '../_type_id.dart';
import '../net.dart';

part 'leader.g.dart';

@HiveType(typeId: TypeId.LeaderWallet)
class LeaderWallet extends Wallet {
  @HiveField(3)
  final String encryptedEntropy;

  LeaderWallet({
    required String walletId,
    required String accountId,
    required this.encryptedEntropy,
    required CipherUpdate cipherUpdate,
  }) : super(
            walletId: walletId,
            accountId: accountId,
            cipherUpdate: cipherUpdate);

  @override
  String toString() => 'LeaderWallet($walletId, $accountId, $encryptedEntropy)';

  @override
  String get encrypted => encryptedEntropy;

  @override
  HDWallet seedWallet(Cipher cipher, {Net net = Net.Main}) => SeedWallet(
        EncryptedEntropy(encrypted, cipher).seed,
        net,
      ).wallet;
}
