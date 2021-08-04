import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 4)
class History with EquatableMixin {
  @HiveField(0)
  String walletId;

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

  History(
      {required this.walletId,
      required this.scripthash,
      required this.height,
      required this.txHash,
      this.txPos,
      this.value});

  @override
  List<Object> get props => [walletId, scripthash, height, txHash];

  @override
  String toString() {
    return 'History(walletId: $walletId, scripthash: $scripthash, txHash: $txHash, height: $height, txPos: $txPos, value: $value)';
  }
}
