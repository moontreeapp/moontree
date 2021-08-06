import 'package:hive/hive.dart';

part 'balance.g.dart';

@HiveType(typeId: 3)
class Balance {
  @HiveField(0)
  int confirmed;

  @HiveField(1)
  int unconfirmed;

  Balance({
    required this.confirmed,
    required this.unconfirmed,
  });
}
