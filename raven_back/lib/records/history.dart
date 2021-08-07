import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

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
  String ticker; // '' for RVN

  History(
      {required this.accountId,
      required this.walletId,
      required this.scripthash,
      required this.height,
      required this.txHash,
      this.txPos = -1,
      this.value = 0,
      this.ticker = ''});

  @override
  List<Object> get props =>
      [accountId, walletId, scripthash, height, txHash, txPos, value, ticker];

  @override
  String toString() {
    return 'History(walletId: $walletId, accountId: $accountId, scripthash: $scripthash, txHash: $txHash, height: $height, txPos: $txPos, value: $value, ticker: $ticker)';
  }
}
