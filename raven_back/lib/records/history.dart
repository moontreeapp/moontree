import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';

part 'history.g.dart';

@HiveType(typeId: 5)
class History with EquatableMixin {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  String walletId;

  @HiveField(2)
  String scripthash;

  @HiveField(3)
  int height;

  @HiveField(4)
  String txHash;

  @HiveField(5)
  int txPos; // -1 for mempool (unconfirmed)

  @HiveField(6)
  int value;

  @HiveField(7)
  Security security;

  History(
      {required this.accountId,
      required this.walletId,
      required this.scripthash,
      required this.height,
      required this.txHash,
      this.txPos = -1,
      this.value = 0,
      this.security = RVN});

  @override
  List<Object> get props => [
        accountId,
        walletId,
        scripthash,
        height,
        txHash,
        txPos,
        value,
        security.symbol
      ];

  @override
  String toString() {
    return 'History(walletId: $walletId, accountId: $accountId, scripthash: $scripthash, txHash: $txHash, height: $height, txPos: $txPos, value: $value, security: $security)';
  }
}
