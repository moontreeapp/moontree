import 'package:raven/records.dart' as records;
import 'package:raven/models/balance.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class BalanceReservoir extends Reservoir<String, records.Balance, Balance> {
  late MultipleIndex byAccount;

  BalanceReservoir() : super(HiveSource('addresses')) {
    var paramsToKey = (accountId, ticker) => '$accountId:${ticker ?? ""}';
    addPrimaryIndex(
        (balance) => paramsToKey(balance.accountId, balance.ticker));

    byAccount = addMultipleIndex('account', (balance) => balance.accountId);
  }

  /// get rvn confirmed and unconfirmed of assets from own trading platform
  Balance getTotalRVN(String accountId) {
    var balances = byAccount.getAll(accountId);
    var rvn = Balance(
        accountId: accountId, ticker: '_', confirmed: 0, unconfirmed: 0);
    return balances.fold(
        rvn, (summing, balance) => balance.ticker == '' ? rvn + balance : rvn);
    // : rvn + fromAssetToRVN(balance.ticker, balance);
  }

  Balance getRVN(String accountId) {
    var balance = get('$accountId:');
    return balance ??
        Balance(accountId: accountId, ticker: '', confirmed: 0, unconfirmed: 0);
  }
}
