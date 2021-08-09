import 'package:hive/hive.dart';

part 'balance.g.dart';

@HiveType(typeId: 3)
class Balance {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  String ticker;

  @HiveField(2)
  int confirmed;

  @HiveField(3)
  int unconfirmed;

  Balance({
    required this.accountId,
    required this.ticker,
    required this.confirmed,
    required this.unconfirmed,
  });
}
