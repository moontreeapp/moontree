import 'package:raven/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

List _paramsToKey(String accountId, Security security) => [accountId, security];

class BalanceReservoir extends Reservoir<List, Balance> {
  late IndexMultiple<List, Balance> byAccount;

  BalanceReservoir([source])
      : super(source ?? HiveSource('balances'),
            (balance) => _paramsToKey(balance.accountId, balance.security)) {
    byAccount = addIndexMultiple('account', (balance) => [balance.accountId]);
  }

  Balance getRVN(String accountId) {
    var balance = get([accountId, RVN]);
    return balance ??
        Balance(
          accountId: accountId,
          security: RVN,
          confirmed: 0,
          unconfirmed: 0,
        );
  }
}
