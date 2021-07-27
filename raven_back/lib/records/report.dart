import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

part 'report.g.dart';

@HiveType(typeId: 2)
class Report {
  @HiveField(0)
  String scripthash;

  @HiveField(1)
  ScripthashBalance balance;

  @HiveField(2)
  ScripthashHistory history;

  @HiveField(3)
  ScripthashUnspent unspent;

  Report(this.scripthash, this.balance, this.history, this.unspent);
}
