import 'package:raven/raven.dart';

String currentAccountId() => settings.currentAccountId;

Account currentAccount() => accounts.primaryIndex.getOne(currentAccountId())!;

BalanceUSD currentBalanceUSD() =>
    services.rates.accountBalanceUSD(currentAccountId(), currentHoldings());

Balance currentBalanceRVN() =>
    services.balances.accountBalance(currentAccount(), RVN);
//balances.getOrZero(currentAccountId());

/// our concept of history isn't the same as transactions - must fill out negative values for sent amounts
List<History> currentTransactions() => currentAccount().histories;

List<Balance> currentHoldings() =>
    services.balances.accountBalances(currentAccount());

List<String> currentHoldingNames() =>
    [for (var balance in currentHoldings()) balance.security.symbol];

Wallet? currentWallet(walletId) => wallets.primaryIndex.getOne(walletId);

Balance currentWalletBalanceRVN(walletId) =>
    services.balances.walletBalance(currentWallet(walletId)!, RVN);

List<Balance> currentWalletHoldings(String walletId) =>
    services.balances.walletBalances(currentWallet(walletId)!);

List<String> currentWalletHoldingNames(String walletId) => [
      for (var balance in currentWalletHoldings(walletId))
        balance.security.symbol
    ];

BalanceUSD currentWalletBalanceUSD(String walletId) =>
    services.rates.accountBalanceUSD(walletId, currentWalletHoldings(walletId));

List<History> currentWalletTransactions(String walletId) =>
    currentWallet(walletId)!.histories;

class Current {
  static Account get account => currentAccount();
  static Balance get balanceRVN => currentBalanceRVN();
  static BalanceUSD get balanceUSD => currentBalanceUSD();
  static List<History> get transactions => currentTransactions();
  static List<Balance> get holdings => currentHoldings();
  static List<String> get holdingNames => currentHoldingNames();

  static Wallet wallet(String walletId) => currentWallet(walletId)!;
  static Balance walletBalanceRVN(String walletId) =>
      currentWalletBalanceRVN(walletId);
  static BalanceUSD walletBalanceUSD(String walletId) =>
      currentWalletBalanceUSD(walletId);
  static List<Balance> walletHoldings(String walletId) =>
      currentWalletHoldings(walletId);
  static List<History> walletTransactions(String walletId) =>
      currentWalletTransactions(walletId);
  static List<String> walletHoldingNames(String walletId) =>
      currentWalletHoldingNames(walletId);
}
