import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

part 'balance.keys.dart';

class BalanceReservoir extends Reservoir<_AccountSecurityKey, Balance> {
  late IndexMultiple<_AccountKey, Balance> byAccount;

  BalanceReservoir([source])
      : super(source ?? HiveSource('balances'), _AccountSecurityKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
  }

  Balance getRVN(String accountId) =>
      primaryIndex.getOne(accountId, RVN) ??
      Balance(
        accountId: accountId,
        security: RVN,
        confirmed: 0,
        unconfirmed: 0,
      );
}
