import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class UnspentWaiter extends Waiter {
  void init() {
    listen(
      'unspents.batchedChanges',
      res.unspents.batchedChanges,
      (List<Change<Unspent>> changes) => handleUnspentChange(changes),
    );
  }

  void handleUnspentChange(List<Change<Unspent>> changes) {
    // don't run during these process, they both automatically recalculate
    // all balances at the end of their processes
    if (services.wallet.leader.newLeaderProcessRunning ||
        services.client.subscribe.startupProcessRunning) {
      return;
    }
    var walletIds = <String>{};
    for (var change in changes) {
      change.when(
          loaded: (loaded) {},
          added: (added) => walletIds.add(added.data.walletId),
          updated: (updated) => walletIds.add(updated.data.walletId),
          removed: (removed) => walletIds.add(removed.data.walletId));
    }
    print('Unspent changes DISCOVERED! $changes $walletIds');
    services.balance.recalculateAllBalances(walletIds: walletIds);
  }
}
