/// this file used to be account_balance.dart but was removed when keeping
/// account balances in sync proved to be more work than it was worth.
/// If we do want to keep aggregate balances, keeping them on wallets would be
/// ideal, then we can, at will aggregate the balances to show account level
/// balances, and wallet balances are easy to keep up to date and synced, as
/// the balance doesn't change as wallets are moved from account to account.
/// Currently, however, this code is not being used.
///
/// is this really necessary... if we make a second layer we have two sources of
/// truth. If we don't we must do filter computation in realtime. I don't think
/// this is really needed for mvp but if we'll eventually have it, might as well
/// now so that all the UI points to the balances, not the history filters...

import 'package:raven_back/extensions/stream/buffer_count_window.dart';
import 'package:raven_back/raven_back.dart';

import 'waiter.dart';

class BalanceWaiter extends Waiter {
  void init() {
    /// new transaction is made / detected:
    /// recalculate affected balance (by security) for that wallet
    //listen('vouts.batchedChanges',
    //    vouts.batchedChanges.bufferCountTimeout(250, Duration(seconds: 10)),
    //    (List<List<Change<Vout>>> unflattenedChanges) {
    //  //var changes = unflattenedChanges.expand((change) => change);
    //  //services.balance.saveChangedBalances(changes.toList());
//
    //  /// incremental updates (above) do not work perfectly on all edge cases
    //  /// thus we simply recalculate all balances each time theres an update
    //  //services.balance.recalculateAllBalances();
//
    //  // well I thought that was the issue but the problem persists so
    //  // we're going to tack on this to the end of the data get process.
    //  // see services.address
    //});
  }
}
