import 'package:hive/hive.dart';

part 'balance.g.dart';

@HiveType(typeId: 6)
class Balance {
  @HiveField(0)
  int confirmed;

  @HiveField(1)
  int unconfirmed;

  Balance(
    this.confirmed,
    this.unconfirmed,
  );
}
