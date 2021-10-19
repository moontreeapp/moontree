import 'package:raven/raven.dart';
import 'package:raven/services/transaction.dart';

String currentAccountId() => settings.currentAccountId;

Account currentAccount() => accounts.primaryIndex.getOne(currentAccountId())!;

BalanceUSD currentBalanceUSD() =>
    services.rates.accountBalanceUSD(currentAccountId(), currentHoldings());

Balance currentBalanceRVN() =>
    services.balances.accountBalance(currentAccount(), securities.RVN);
//balances.getOrZero(currentAccountId());

/// our concept of history isn't the same as transactions - must fill out negative values for sent amounts
Set<Transaction> currentTransactions() => currentAccount().transactions;

List<TransactionRecord> currentCompiledTransactions() =>
    services.transactions.getTransactionRecords(account: currentAccount());

List<Balance> currentHoldings() =>
    services.balances.accountBalances(currentAccount());

List<String> currentHoldingNames() =>
    [for (var balance in currentHoldings()) balance.security.symbol];

Wallet? currentWallet(walletId) => wallets.primaryIndex.getOne(walletId);

Balance currentWalletBalanceRVN(walletId) =>
    services.balances.walletBalance(currentWallet(walletId)!, securities.RVN);

List<Balance> currentWalletHoldings(String walletId) =>
    services.balances.walletBalances(currentWallet(walletId)!);

List<String> currentWalletHoldingNames(String walletId) => [
      for (var balance in currentWalletHoldings(walletId))
        balance.security.symbol
    ];

BalanceUSD currentWalletBalanceUSD(String walletId) =>
    services.rates.accountBalanceUSD(walletId, currentWalletHoldings(walletId));

Set<Transaction> currentWalletTransactions(String walletId) =>
    currentWallet(walletId)!.transactions;

List<TransactionRecord> currentWalletCompiledTransactions(String walletId) =>
    services.transactions
        .getTransactionRecords(wallet: currentWallet(walletId)!);

class Current {
  static Account get account => currentAccount();
  static Balance get balanceRVN => currentBalanceRVN();
  static BalanceUSD get balanceUSD => currentBalanceUSD();
  static Set<Transaction> get transactions => currentTransactions();
  static List<TransactionRecord> get compiledTransactions =>
      currentCompiledTransactions();
  static List<Balance> get holdings => currentHoldings();
  static List<String> get holdingNames => currentHoldingNames();

  static Wallet wallet(String walletId) => currentWallet(walletId)!;
  static Balance walletBalanceRVN(String walletId) =>
      currentWalletBalanceRVN(walletId);
  static BalanceUSD walletBalanceUSD(String walletId) =>
      currentWalletBalanceUSD(walletId);
  static List<Balance> walletHoldings(String walletId) =>
      currentWalletHoldings(walletId);
  static Set<Transaction> walletTransactions(String walletId) =>
      currentWalletTransactions(walletId);
  static List<String> walletHoldingNames(String walletId) =>
      currentWalletHoldingNames(walletId);
  static List<TransactionRecord> walletCompiledTransactions(String walletId) =>
      currentWalletCompiledTransactions(walletId);
}
