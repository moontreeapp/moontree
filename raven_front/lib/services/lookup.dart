import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';

class Current {
  static String get walletId => res.settings.currentWalletId;

  static Wallet get wallet => res.wallets.primaryIndex.getOne(walletId)!;

  static Balance get balanceRVN =>
      services.balance.walletBalance(wallet, res.securities.RVN);

  static BalanceUSD? get balanceUSD =>
      services.rate.walletBalanceUSD(walletId, holdings);

  static Set<Transaction> get transactions => wallet.transactions;

  static List<TransactionRecord> get compiledTransactions =>
      services.transaction.getTransactionRecords(wallet: wallet);

  static List<Balance> get holdings => services.balance.walletBalances(wallet);

  static List<String> get holdingNames =>
      [for (var balance in holdings) balance.security.symbol];

  static Iterable<String> get adminNames => holdings
      .where((Balance balance) => balance.security.asset?.isAdmin ?? false)
      .map((Balance balance) => balance.security.symbol);

  static List<TransactionRecord> walletCompiledTransactions() =>
      services.transaction.getTransactionRecords(wallet: wallet);
}
