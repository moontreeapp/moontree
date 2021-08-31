import 'package:reservoir/reservoir.dart';

import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/services/services.dart';

class AccountBalanceWaiter extends Waiter {
  HistoryReservoir histories;
  BalanceService balanceService;

  AccountBalanceWaiter(this.histories, this.balanceService) : super();

  @override
  void init() {
    listeners.add(histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen((List<List<Change>> unflattenedChanges) {
      var changes = unflattenedChanges.expand((change) => change);
      balanceService.saveChangedBalances(changes.toList());
    }));
  }
}
