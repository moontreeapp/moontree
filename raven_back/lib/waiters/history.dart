/// when activity is detected on an address we download a list of txids (its history)
/// this picks it up and saves them by wallet-exposure. We wait till no history was
/// found for that wallet-exposure then we go download all the transactions for it.
/// doing so allows us to know when we should calculate the balance for it: right
/// after all the transactions are downloaded for that wallet-exposure...

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/wallet.dart';
import 'waiter.dart';

class HistoryWaiter extends Waiter {
  Map<String, List<String>> txsByWalletExposureKeys = {};
  Map<String, List<String>> addressesByWalletExposureKeys = {};

  void init() => listen(
      'streams.wallet.transactions',
      streams.wallet.transactions,
      (WalletExposureTransactions? keyedTransactions) =>
          keyedTransactions == null
              ? doNothing(/* initial state */)
              : keyedTransactions.transactionIds.isEmpty
                  ? () {
                      remember(keyedTransactions);
                      pullIf(keyedTransactions);
                    }()
                  : remember(keyedTransactions));

  void doNothing() {}

  void remember(WalletExposureTransactions keyedTransactions) {
    addressesByWalletExposureKeys[keyedTransactions.key] =
        (addressesByWalletExposureKeys[keyedTransactions.key] ?? []) +
            [keyedTransactions.address.id];
    txsByWalletExposureKeys[keyedTransactions.key] =
        (txsByWalletExposureKeys[keyedTransactions.key] ?? []) +
            keyedTransactions.transactionIds.toList();
  }

  Future<void> pullIf(WalletExposureTransactions keyedTransactions) async {
    var addressCount =
        keyedTransactions.address.exposure == NodeExposure.Internal
            ? keyedTransactions.address.wallet?.highestSavedInternalIndex ?? 0
            : keyedTransactions.address.wallet?.highestSavedExternalIndex ?? 0;
    print(
        '${keyedTransactions.key.cutOutMiddle()} address Count: $addressCount vs: ${addressesByWalletExposureKeys[keyedTransactions.key]?.length}');
    if ((addressesByWalletExposureKeys[keyedTransactions.key]?.length ?? 0) >=
        (addressCount)) {
      await pull(keyedTransactions);
    }
  }

  Future<void> pull(WalletExposureTransactions keyedTransactions) async {
    var txs = txsByWalletExposureKeys.containsKey(keyedTransactions.key)
        ? txsByWalletExposureKeys[keyedTransactions.key]
        : null;
    if (txs != null) {
      txsByWalletExposureKeys[keyedTransactions.key] = [];
      await getTransactionsAndCalculateBalance(
          keyedTransactions.address.walletId,
          keyedTransactions.address.exposure,
          txs);
    }
  }

  // if we could get a batch of transactions that'd be better...
  Future<void> getTransactionsAndCalculateBalance(
    String walletId,
    NodeExposure exposure,
    Iterable<String> transactionIds,
  ) async {
    for (var transactionId in transactionIds) {
      await getTransaction(transactionId);
    }
    // calculate balances (for that wallet exposure)
    //var done =
    //    await services.history.produceAddressOrBalanceFor(walletId, exposure);
    await services.history.produceAddressOrBalance();
  }

  Future getTransaction(String transaction) async =>
      await services.history.getTransaction(transaction);
}
