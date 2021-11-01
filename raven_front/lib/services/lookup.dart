import 'package:raven/raven.dart';
import 'package:raven/services/transaction.dart';

class Current {
  static String get accountId => settings.currentAccountId;

  static Account get account => accounts.primaryIndex.getOne(accountId)!;

  static Balance get balanceRVN =>
      services.balance.accountBalance(account, securities.RVN);

  static BalanceUSD get balanceUSD =>
      services.rate.accountBalanceUSD(accountId, holdings);

  static Set<Transaction> get transactions => account.transactions;

  static List<TransactionRecord> get compiledTransactions =>
      services.transaction.getTransactionRecords(account: account);

  static List<Balance> get holdings =>
      services.balance.accountBalances(account);
  static List<String> get holdingNames =>
      [for (var balance in holdings) balance.security.symbol];

  static Wallet wallet(String walletId) =>
      wallets.primaryIndex.getOne(walletId)!;

  static Balance walletBalanceRVN(String walletId) =>
      services.balance.walletBalance(wallet(walletId), securities.RVN);

  static BalanceUSD walletBalanceUSD(String walletId) =>
      services.rate.accountBalanceUSD(walletId, walletHoldings(walletId));

  static List<Balance> walletHoldings(String walletId) =>
      services.balance.walletBalances(wallet(walletId));

  static Set<Transaction> walletTransactions(String walletId) =>
      wallet(walletId).transactions;

  static List<String> walletHoldingNames(String walletId) =>
      [for (var balance in walletHoldings(walletId)) balance.security.symbol];

  static List<TransactionRecord> walletCompiledTransactions(String walletId) =>
      services.transaction.getTransactionRecords(wallet: wallet(walletId));
}
