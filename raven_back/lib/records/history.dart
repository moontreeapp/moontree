import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 3)
class History with EquatableMixin {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  String scripthash;

  @HiveField(2)
  int height;

  @HiveField(3)
  String txHash;

  @HiveField(4)
  int? txPos;

  @HiveField(5)
  int? value;

  History(this.accountId, this.scripthash, this.height, this.txHash,
      {this.txPos, this.value});

  @override
  List<Object> get props => [accountId, scripthash, height, txHash];

  @override
  String toString() {
    return 'History(accountId: $accountId, scripthash: $scripthash, txHash: $txHash, height: $height, txPos: $txPos, value: $value)';
  }
}
