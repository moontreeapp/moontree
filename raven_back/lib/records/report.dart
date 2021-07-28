import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

part 'report.g.dart';

@HiveType(typeId: 2)
class Report {
  @HiveField(0)
  String scripthash;

  @HiveField(1)
  String accountId;

  @HiveField(2)
  ScripthashBalance balance;

  @HiveField(3)
  ScripthashHistory history;

  @HiveField(4)
  ScripthashUnspent unspent;

  Report(this.scripthash, this.accountId, this.balance, this.history,
      this.unspent);
}
