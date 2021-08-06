import 'dart:async';

import 'package:collection/collection.dart';

import 'package:raven/models.dart';
import 'package:raven/models/indexed_balance.dart' as indexed;
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/balance.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/services/service.dart';
import 'package:raven/buffer_count_window.dart';

class Bal {
  final int confirmed;
  final int unconfirmed;

  Bal(this.confirmed, this.unconfirmed);
}

class AccountBalanceService extends Service {
  AccountReservoir accounts;
  BalanceReservoir balances;
  HistoryReservoir histories;

  late StreamSubscription<List<Change>> listener;

  AccountBalanceService(this.accounts, this.balances, this.histories) : super();

  @override
  void init() {
    listener = histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen(calculateBalance);
  }

  // runs it for affected account-ticker combinations
  void calculateBalance(changes) {
    var combos = [];
    changes.forEach((History history) {
      if (!combos.contains([history.accountId, history.ticker])) {
        combos.add([history.accountId, history.ticker]);
      }
    });
    for (var accountIdTicker in combos) {
      var accountId = accountIdTicker[0];
      var ticker = accountIdTicker[1];
      var account = accounts.get(accountId);
      account.balances[ticker] = Balance(
          confirmed: histories
                  .unspentsByAccount(accountId, ticker: ticker)
                  .fold(0, (sum, history) => sum ?? 0 + history.value) ??
              0,
          unconfirmed: histories
                  .unconfirmedByAccount(accountId, ticker: ticker)
                  .fold(0, (sum, history) => sum ?? 0 + history.value) ??
              0);
    }
  }

  // runs it for all accounts and all tickers
  void recalculateBalance(_changes) {
    if (_changes.length == 0) {
      return;
    }
    for (var accountId in histories.byAccount.keys) {
      var hists = histories.byAccount.getAll(accountId);

      var balanceByTicker = hists
          .groupFoldBy((History history) => history.ticker,
              (Balance? previous, History history) {
        var balance = previous ?? Balance(confirmed: 0, unconfirmed: 0);
        return Balance(
            confirmed:
                balance.confirmed + (history.txPos > -1 ? history.value : 0),
            unconfirmed: balance.unconfirmed +
                (history.txPos == -1 ? history.value : 0));
      });

      balanceByTicker.forEach((ticker, bal) {
        var balance = indexed.Balance(
            accountId: accountId,
            ticker: ticker,
            confirmed: bal.confirmed,
            unconfirmed: bal.unconfirmed);
        balances.save(balance);
      });
    }
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
