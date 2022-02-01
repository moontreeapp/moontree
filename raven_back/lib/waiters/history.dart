/// when activity is detected on an address we download a list of txids (its history)
/// this picks it up and downloads them.
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/wallet.dart';
import 'waiter.dart';

class HistoryWaiter extends Waiter {
  int requiredGap = services.wallet.leader.requiredGap;
  Map<String, Map<NodeExposure, int>> gaps = {};
  Set<String> backlog = {};
  Set<String> retrieved = {};

  void init() {
    listen(
      'streams.address.history',
      streams.address.history,
      (Iterable<String>? transactions) => transactions == null
          ? doNothing(/* initial state */)
          : gapsFilled()
              ? handleHistories(transactions)
              : backlog.addAll(transactions),
    );

    listen(
      'streams.client.connected',
      streams.client.connected,
      (bool connected) => connected ? handleBacklog() : doNothing(),
    );

    listen(
      'streams.address.empty',
      streams.address.empty,
      (Address? address) =>
          address == null ? doNothing() : handleEmptyPull(address),
    );

    initGaps();
  }

  void doNothing() {}

  bool initGaps() {
    for (var wallet in res.wallets.leaders) {
      for (var exposure in [NodeExposure.External, NodeExposure.Internal]) {
        insertKeys(wallet.walletId, exposure);
        gaps[wallet.walletId]?[exposure] =
            services.wallet.leader.currentGap(wallet, exposure);
      }
    }
    return true;
  }

  bool gapFilled(Address address) =>
      (gaps[address.wallet!.walletId]?[address.exposure] ?? 0) >= requiredGap;

  bool gapsFilled() {
    for (var wallet in res.wallets.leaders) {
      insertKeys(wallet.walletId, NodeExposure.External);
      insertKeys(wallet.walletId, NodeExposure.Internal);
    }
    for (var walletId in gaps.keys) {
      for (var exposure in gaps[walletId]!.keys) {
        if (gaps[walletId]![exposure]! < requiredGap) return false;
      }
    }
    return true;
  }

  void incrementGap(Address address) {
    insertKeys(address.wallet!.walletId, address.exposure);
    gaps[address.wallet!.walletId]![address.exposure] =
        gaps[address.wallet!.walletId]![address.exposure]! + 1;
  }

  void insertKeys(String walletId, NodeExposure exposure) {
    if (!gaps.containsKey(walletId)) {
      gaps[walletId] = {exposure: 0};
    }
    if (!gaps[walletId]!.containsKey(exposure)) {
      gaps[walletId]![exposure] = 0;
    }
  }

  void handleHistories(Iterable<String> transactions) {
    //if (await services.history.getTransactions(transactions)) {
    //  backlog.removeAll(transactions);
    //} else {
    //  backlog.addAll(transactions);
    //}
    for (var transactionId in transactions) {
      handleHistory(transactionId);
    }
  }

  Future handleHistory(String transaction) async {
    if (!retrieved.contains(transaction)) {
      if (await services.history.getTransaction(transaction)) {
        retrieved.add(transaction);
      } else {
        backlog.add(transaction);
      }
    }
  }

  Future handleBacklog() async {
    cleanBacklog();
    if (backlog.isNotEmpty) {
      //if (await services.history.getTransactions(backlog.toList())) {
      //  backlog.clear();
      //}
      try {
        for (var transactionId in backlog) {
          await handleHistory(transactionId);
        }
      } catch (e) {
        //print("please don't modify backlog while something loops through it: $e");
      }
    }
    await areWeAllDone();
  }

  void cleanBacklog() {
    try {
      backlog.removeAll(retrieved);
      retrieved.removeAll(retrieved.where((item) => !backlog.contains(item)));
    } catch (e) {
      //print("please don't modify backlog while something loops through it: $e");
    }
  }

  Future areWeAllDone() async {
    cleanBacklog();
    if (backlog.isEmpty) {
      var done = await services.history.produceAddressOrBalance();
      if (done) {
        streams.address.empty.add(null);
      }
    }
  }

  void handleEmptyPull(Address address) {
    incrementGap(address);
    if (gapFilled(address)) {
      if (gapsFilled()) {
        print('filled all gaps: $gaps');
        handleBacklog();
      }
    } else {
      streams.wallet.deriveAddress.add(DeriveLeaderAddress(
        leader: address.wallet as LeaderWallet,
        exposure: address.exposure,
      ));
    }
  }
}
