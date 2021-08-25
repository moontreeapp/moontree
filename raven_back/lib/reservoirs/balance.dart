import 'package:raven/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

String _paramsToKey(String accountId, [Security? base]) => base == null
    ? '$accountId::'
    : '$accountId:${base.symbol}:${base.securityType}';

class BalanceReservoir extends Reservoir<String, Balance> {
  late IndexMultiple<String, Balance> byAccount;

  BalanceReservoir([source])
      : super(source ?? HiveSource('balances'),
            (balance) => _paramsToKey(balance.accountId, balance.security)) {
    byAccount = addIndexMultiple(
        'account', (balance) => _paramsToKey(balance.accountId));
  }

  Balance? getOne(String accountId, [Security? base]) =>
      primaryIndex.getOne(_paramsToKey(accountId, base));

  Balance getRVN(String accountId) {
    var balance = getOne(accountId, RVN);
    return balance ??
        Balance(
          accountId: accountId,
          security: RVN,
          confirmed: 0,
          unconfirmed: 0,
        );
  }
}
