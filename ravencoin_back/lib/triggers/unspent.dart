import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class UnspentWaiter extends Trigger {
  void init() {
    when(
      thereIsA: pros.unspents.changes,
      doThis: (Change<Unspent> change) => handleUnspentChange(change),
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
