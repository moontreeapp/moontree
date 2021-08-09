import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';

part 'balance.g.dart';

@HiveType(typeId: 3)
class Balance {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  Security security;

  @HiveField(2)
  int confirmed;

  @HiveField(3)
  int unconfirmed;

  Balance({
    required this.accountId,
    required this.security,
    required this.confirmed,
    required this.unconfirmed,
  });
}
