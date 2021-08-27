import 'package:raven/records.dart';
import 'package:raven/records/security.dart';
import 'package:raven/utils/enum.dart';
import 'package:reservoir/reservoir.dart';

part 'balance.keys.dart';

class BalanceReservoir extends Reservoir<_AccountSecurityKey, Balance> {
  late IndexMultiple<_AccountKey, Balance> byAccount;

  BalanceReservoir([source])
      : super(source ?? HiveSource('balances'), _AccountSecurityKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
  }

  Balance getRVN(String accountId) {
    var balances = primaryIndex.getAll(accountId, RVN);
    if (balances.isNotEmpty) {
      return balances.first;
    } else {
      return Balance(
        accountId: accountId,
        security: RVN,
        confirmed: 0,
        unconfirmed: 0,
      );
    }
  }
}
