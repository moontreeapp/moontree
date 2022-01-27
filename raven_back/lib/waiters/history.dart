/// when activity is detected on an address we download a list of txids (its history)
/// this picks it up and downloads them.
import 'package:raven_back/raven_back.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'waiter.dart';

class HistoryWaiter extends Waiter {
  Set<ScripthashHistory> backlog = {};

  void init() {
    listen(
      'streams.address.history',
      streams.address.history,
      (List<ScripthashHistory>? transactions) => transactions == null
          ? doNothing(/* initial state */)
          : handleHistory(transactions),
    );

    listen(
      'streams.client.connected',
      streams.client.connected,
      (bool connected) => connected ? handleBacklog() : doNothing(),
    );
  }

  void doNothing() {}

  Future handleHistory(List<ScripthashHistory> transactions) async {
    if (await services.history.getTransactions(transactions)) {
      backlog.removeAll(transactions);
      await areWeAllDone();
    } else {
      backlog.addAll(transactions);
    }
  }

  Future handleBacklog() async {
    if (backlog.isNotEmpty) {
      if (await services.history.getTransactions(backlog.toList())) {
        backlog.clear();
        await areWeAllDone();
      }
    }
  }

  Future areWeAllDone() async {
    print('got into areWeAllDone');
    print(backlog);
    if (backlog.isEmpty && streams.address.empty.value == true) {
      var done = await services.history.produceAddressOrBalance();
      print(done);
      if (done) {
        streams.address.empty.add(null);
      }
    }
  }
}
