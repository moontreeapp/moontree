import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/waiters/waiter.dart';

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
        loaded: (Loaded<Unspent> loaded) {},
        added: (Added<Unspent> added) async => recalculateBalancesIfNecessary(),
        updated: (Updated<Unspent> updated) async =>
            recalculateBalancesIfNecessary(),
        removed: (Removed<Unspent> removed) async =>
            recalculateBalancesIfNecessary());
  }

  Future<void> recalculateBalancesIfNecessary() async {
    final Wallet wallet = services.wallet.currentWallet;
    if (wallet.balances.isNotEmpty) {
      await services.balance
          .recalculateAllBalances(walletIds: <String>{wallet.id});
      streams.app.wallet.refresh.add(true);
    }
  }
}
