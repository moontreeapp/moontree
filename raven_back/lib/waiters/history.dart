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
  Set<String> pulledWalletExposureKeys = {};
  List<Future<Null>> futures = [];

  void init() => listen(
        'streams.wallet.transactions',
        streams.wallet.transactions,
        (WalletExposureTransactions? keyedTransactions) async {
          if (keyedTransactions != null) {
            if (keyedTransactions.transactionIds.isEmpty) {
              remember(keyedTransactions);
              await deriveOrPull(keyedTransactions);
            } else {
              remember(keyedTransactions);
              //deriveIf(keyedTransactions);
            }
          }
        },
      );

  void doNothing() {}

  void remember(WalletExposureTransactions keyedTransactions) {
    addressesByWalletExposureKeys[keyedTransactions.key] =
        (addressesByWalletExposureKeys[keyedTransactions.key] ?? []) +
            [keyedTransactions.address.id];
    txsByWalletExposureKeys[keyedTransactions.key] =
        (txsByWalletExposureKeys[keyedTransactions.key] ?? []) +
            keyedTransactions.transactionIds.toList();
  }

  Future<void> deriveOrPull(
      WalletExposureTransactions keyedTransactions) async {
    if (!await deriveIf(keyedTransactions)) {
      await pullIf(keyedTransactions);
    }
  }

  Future<bool> deriveIf(WalletExposureTransactions keyedTransactions) async {
    var leader = keyedTransactions.address.wallet!;
    var exposure = keyedTransactions.address.exposure;
    if (leader is LeaderWallet) {
      if (!services.wallet.leader.gapSatisfied(leader, exposure)) {
        streams.wallet.deriveAddress
            .add(DeriveLeaderAddress(leader: leader, exposure: exposure));
        return true;
      }
      print('GAP SATISFIED');
    }
    return false;
  }

  Future<void> pullIf(WalletExposureTransactions keyedTransactions) async {
    var addressCount = keyedTransactions.address.wallet
            ?.getHighestSavedIndex(keyedTransactions.address.exposure) ??
        0;
    if ((addressesByWalletExposureKeys[keyedTransactions.key]?.length ?? 0) >=
        addressCount) {
      pulledWalletExposureKeys.add(keyedTransactions.key);
      await services.download.unspents.pull(
          scripthashes:
              addressesByWalletExposureKeys[keyedTransactions.key] ?? []);
      await pullTransactions(keyedTransactions);
    }
  }

  Future<void> pullTransactions(
    WalletExposureTransactions keyedTransactions,
  ) async {
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

  Future<void> manualPull({
    required String keyedTransactionsKey,
    required String walletId,
    required NodeExposure exposure,
  }) async {
    var txs = txsByWalletExposureKeys.containsKey(keyedTransactionsKey)
        ? txsByWalletExposureKeys[keyedTransactionsKey]
        : null;
    if (txs != null) {
      txsByWalletExposureKeys[keyedTransactionsKey] = [];
      await getTransactionsAndCalculateBalance(walletId, exposure, txs);
    }
  }

  // if we could get a batch of transactions that'd be better...
  Future<void> getTransactionsAndCalculateBalance(
    String walletId,
    NodeExposure exposure,
    Iterable<String> transactionIds,
  ) async {
    await services.download.history.getTransactions(transactionIds);
    //if (futureItems != null) {
    //  futures = futures + futureItems;
    //}

    // List<Tx> results = await Future.wait<Tx>(futures);

    //for (var transactionId in transactionIds) {
    //  await services.download.history.getTransaction(transactionId);
    //}
    // calculate balances (for that wallet exposure)
    //var done =
    //    await services.download.history.produceAddressOrBalanceFor(walletId, exposure);

    /// alternative to above and alternative to just trying for everything everytime...
    /// if everything looks empty then we should try to calculate balances, and or derive again for all wallets.
    /// if we can reliably get to [0,0...] then run balance, we can probably avoid the
    /// current problem we're seeing: balances are calculated before all transactions have been
    /// downloaded resulting in the wrong balance displaying first then being replaced by the correct one.
    //if ([
    //  for (var t in txsByWalletExposureKeys.keys)
    //    txsByWalletExposureKeys[t]?.length
    //].every((e) => e == 0)) {
    // above is not working as desired.
    /// to avoid downloading the actual transactions until all the unspents have been downloaded:
    /// if each wallet-exposure has pulled the history for all of it's addresses...
    //for (var leader in res.wallets.leaders) {
    //  for (var exposure in [NodeExposure.Internal, NodeExposure.External]) {
    //    if (!services.wallet.leader.gapSatisfied(leader, exposure) ||
    //        !((addressesByWalletExposureKeys[
    //                        WalletExposureTransactions.produceKey(
    //                            leader.id, exposure)]
    //                    ?.length ??
    //                0) >=
    //            leader.getHighestSavedIndex(exposure))) {
    //      return;
    //    }
    //  }
    //}
    /// instead of looking it up each time, just reference a cache:
    //print(
    //    'pulledWalletExposureKeys.length ${pulledWalletExposureKeys.length} addressesByWalletExposureKeys.keys.length ${addressesByWalletExposureKeys.keys.length}');
    //if (pulledWalletExposureKeys.length ==
    //    addressesByWalletExposureKeys.keys.length) {
    await services.download.history.produceAddressOrBalance(futures);
    //}
    //}
  }
}
