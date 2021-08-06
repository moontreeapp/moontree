import 'package:raven/init/reservoirs.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/models/balance.dart';
import 'package:raven/records.dart' as records;

class BalanceReservoir extends Reservoir<String, records.Balance, Balance> {
  late MultipleIndex byAccount;

  BalanceReservoir() : super(HiveSource('addresses')) {
    var paramsToKey = (accountId, ticker) => '$accountId:${ticker ?? ""}';
    addPrimaryIndex(
        (balance) => paramsToKey(balance.accountId, balance.ticker));

    byAccount = addMultipleIndex('account', (balance) => balance.accountId);
  }
}
