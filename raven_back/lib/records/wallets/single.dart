import 'package:hive/hive.dart';
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
  }) : super(walletId: walletId, accountId: accountId);

  @override
  String toString() => 'SingleWallet($walletId, $accountId, $encryptedWIF)';
}
