import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';

class Current {
  static String get walletId => pros.settings.currentWalletId;

  static Wallet get wallet => pros.wallets.primaryIndex.getOne(walletId)!;

  static Balance get balanceRVN =>
      services.balance.walletBalance(wallet, pros.securities.RVN);

  static Balance get balanceCurrency => services.balance.walletBalance(
      wallet,
      pros.settings.chain == Chain.ravencoin
          ? pros.securities.RVN
          : pros.settings.chain == Chain.evrmore
              ? pros.securities.EVR
              : pros.securities.RVN // default usd?
      );

  static Set<Transaction> get transactions => wallet.transactions;

  static List<Balance> get holdings => services.balance.walletBalances(wallet);

  static List<String> get holdingNames =>
      [for (var balance in holdings) balance.security.symbol];

  static Iterable<String> get adminNames => holdings
      .where((Balance balance) => balance.security.asset?.isAdmin ?? false)
      .map((Balance balance) => balance.security.symbol);

  static Iterable<String> get qualifierNames => holdings
      .where((Balance balance) => balance.security.asset?.isQualifier ?? false)
      .map((Balance balance) => balance.security.symbol);

  static List<TransactionRecord> walletCompiledTransactions() =>
      services.transaction.getTransactionRecords(wallet: wallet);
}
