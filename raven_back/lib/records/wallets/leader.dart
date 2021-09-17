import 'package:hive/hive.dart';
import 'package:raven/records/wallets/wallet.dart';

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
  }) : super(walletId: walletId, accountId: accountId);

  @override
  String toString() => 'LeaderWallet($walletId, $accountId, $encryptedEntropy)';
}
