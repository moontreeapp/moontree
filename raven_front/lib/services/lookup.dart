import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';

class Current {
  /// account ///

  static String get accountId => res.settings.currentAccountId;

  static Account get account => res.accounts.primaryIndex.getOne(accountId)!;

  static Balance get balanceRVN =>
      services.balance.accountBalance(account, res.securities.RVN);

  static BalanceUSD? get balanceUSD =>
      services.rate.accountBalanceUSD(accountId, holdings);

  static Set<Transaction> get transactions => account.transactions;

  static List<TransactionRecord> get compiledTransactions =>
      services.transaction.getTransactionRecords(account: account);

  static List<Balance> get holdings =>
      services.balance.accountBalances(account);
  static List<String> get holdingNames =>
      [for (var balance in holdings) balance.security.symbol];

  static Iterable<String> get adminNames => holdings
      .where((Balance balance) => balance.security.asset?.isAdmin ?? false)
      .map((Balance balance) => balance.security.symbol);

  /// wallet ///

  static Wallet wallet(String walletId) =>
      res.wallets.primaryIndex.getOne(walletId)!;

  static Balance walletBalanceRVN(String walletId) =>
      services.balance.walletBalance(wallet(walletId), res.securities.RVN);

  static BalanceUSD? walletBalanceUSD(String walletId) =>
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
