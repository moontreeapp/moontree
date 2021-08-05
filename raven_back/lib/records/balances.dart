import 'package:hive/hive.dart';
import 'package:raven/records/balance.dart';

part 'balances.g.dart';

@HiveType(typeId: 4)
class Balances {
  @HiveField(0)
  Map<String, Balance> balances;

  Balances({required this.balances});
}
