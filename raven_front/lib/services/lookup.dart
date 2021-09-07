import 'package:raven/raven.dart';

String currentAccountId() => settings.currentAccountId;

// should never get called...
Account makeAccount() {
  accountGenerationService.makeAndAwaitSaveAccount('Primary');
  var account;
  while (accounts.primaryIndex.getAny() != null) {
    // await alternative.
    // (should never happen as user doesn't have ability to delete all accounts)
  }
  account = accounts.primaryIndex.getAny();
  settings.savePreferredAccountId(account.id);
  return account;
}

Account currentAccount() =>
    accounts.primaryIndex.getOne(currentAccountId()) ??
    accounts.primaryIndex.getAny() ??
    makeAccount();

BalanceUSD currentBalanceUSD() =>
    ratesService.accountBalanceUSD(currentAccountId());

Balance currentBalanceRVN() => balances.getOrZero(currentAccountId());

/// our concept of history isn't the same as transactions - must fill out negative values for sent amounts
List<History> currentTransactions() =>
    histories.byAccount.getAll(currentAccountId()).toList();

/// our concept of unspents isn't the same as holdings - the aggregate per asset is a holding...
List<Balance> currentHoldings() {
  var accountBalances = balances.byAccount.getAll(currentAccountId());
  // ignore: omit_local_variable_types
  Map<Security, Balance> holdings = {};
  for (var balance in accountBalances) {
    if (holdings.keys.contains(balance.security)) {
      holdings[balance.security] = holdings[balance.security]! + balance;
    } else {
      holdings[balance.security] = balance;
    }
  }
  return holdings.values.toList();
}

class Current {
  static Account get account => currentAccount();
  static Balance get balanceRVN => currentBalanceRVN();
  static BalanceUSD get balanceUSD => currentBalanceUSD();
  static List<History> get transactions => currentTransactions();
  static List<Balance> get holdings => currentHoldings();
}
