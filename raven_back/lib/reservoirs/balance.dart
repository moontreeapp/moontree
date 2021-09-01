import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

part 'balance.keys.dart';

class BalanceReservoir extends Reservoir<_AccountSecurityKey, Balance> {
  late IndexMultiple<_AccountKey, Balance> byAccount;
  // maybe by wallet too?

  BalanceReservoir([source])
      : super(source ?? HiveSource('balances'), _AccountSecurityKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
  }

  Balance getOrZero(String accountId, {Security security = RVN}) =>
      primaryIndex.getOne(accountId, security) ??
      Balance(
        accountId: accountId,
        security: security,
        confirmed: 0,
        unconfirmed: 0,
      );
}
