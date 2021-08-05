import 'package:hive/hive.dart';

part 'balance.g.dart';

@HiveType(typeId: 3)
class Balance {
  @HiveField(0)
  int ticker;

  @HiveField(1)
  int confirmed;

  @HiveField(2)
  int unconfirmed;

  Balance({
    required this.ticker,
    required this.confirmed,
    required this.unconfirmed,
  });
}
