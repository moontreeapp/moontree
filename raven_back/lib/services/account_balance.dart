import 'dart:async';

import 'package:ordered_set/ordered_set.dart';
import 'package:collection/collection.dart';

import 'package:raven/models.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/balance.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/services/service.dart';
import 'package:raven/buffer_count_window.dart';

class Bal {
  final int confirmed;
  final int unconfirmed;

  Bal(this.confirmed, this.unconfirmed);
}

class AccountBalanceService extends Service {
  BalanceReservoir balances;
  HistoryReservoir histories;

  late StreamSubscription<List<Change>> listener;

  AccountBalanceService(this.balances, this.histories) : super();

  @override
  void init() {
    listener = histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen(recalculateBalance);
  }

  void recalculateBalance(_changes) {
    for (var accountId in histories.byAccount.keys) {
      var hists = histories.byAccount.getAll(accountId);

      var balanceByTicker = hists
          .groupFoldBy((History history) => history.ticker ?? '',
              (Bal? previous, History history) {
        var bal = previous ?? Bal(0, 0);
        return Bal(bal.confirmed + (history.txPos != null ? history.value : 0),
            bal.unconfirmed + (history.txPos == null ? history.value : 0));
      });

      balanceByTicker.forEach((ticker, bal) {
        var balance = Balance(
            accountId: accountId,
            ticker: ticker == '' ? null : ticker,
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
