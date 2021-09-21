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

import 'package:reservoir/reservoir.dart';

import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/raven.dart';

import 'waiter.dart';

class BalanceWaiter extends Waiter {
  void init() {
    /// new transaction is made / detected:
    /// recalculate affected balance (by security) for that wallet
    listeners.add(histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen((List<List<Change>> unflattenedChanges) {
      var changes = unflattenedChanges.expand((change) => change);
      services.balances.saveChangedBalances(changes.toList());
    }));

    // unlike account balances, no other triggers need to be considered.
  }
}
