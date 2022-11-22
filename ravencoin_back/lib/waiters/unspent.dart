import 'package:ravencoin_back/ravencoin_back.dart';
import 'waiter.dart';

class UnspentWaiter extends Waiter {
  void init() {
    listen(
      'unspents.changes',
      pros.unspents.changes,
      (Change<Unspent> change) => handleUnspentChange(change),
    );
  }

  void handleUnspentChange(Change<Unspent> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) async => await recalculateBalancesIfNecessary(),
        updated: (updated) async => await recalculateBalancesIfNecessary(),
        removed: (removed) async => await recalculateBalancesIfNecessary());
  }

  Future<void> recalculateBalancesIfNecessary() async {
    final wallet = services.wallet.currentWallet;
    if (wallet.balances.isNotEmpty) {
      await services.balance.recalculateAllBalances(walletIds: {wallet.id});
      streams.app.wallet.refresh.add(true);
    }
  }
}
