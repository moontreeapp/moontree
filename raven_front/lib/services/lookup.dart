import 'package:raven/raven.dart';

String currentAccountId() => settings.currentAccountId;

Account currentAccount() => accounts.primaryIndex.getOne(currentAccountId())!;

BalanceUSD currentBalanceUSD() => ratesService
    .accountBalanceUSD(currentAccountId(), holdings: currentHoldings());

Balance currentBalanceRVN() =>
    balanceService.sumBalance(currentAccountId(), RVN);
//balances.getOrZero(currentAccountId());

/// our concept of history isn't the same as transactions - must fill out negative values for sent amounts
List<History> currentTransactions() =>
    histories.byAccount.getAll(currentAccountId()).toList();

List<Balance> currentHoldings() =>
    balanceService.sumBalances(currentAccountId());

class Current {
  static Account get account => currentAccount();
  static Balance get balanceRVN => currentBalanceRVN();
  static BalanceUSD get balanceUSD => currentBalanceUSD();
  static List<History> get transactions => currentTransactions();
  static List<Balance> get holdings => currentHoldings();
}
