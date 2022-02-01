/// when activity is detected on an address we download a list of txids (its history)
/// this picks it up and downloads them.
import 'package:raven_back/raven_back.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'waiter.dart';

class HistoryWaiter extends Waiter {
  Set<String> backlog = {};

  void init() {
    listen(
      'streams.address.uniqueHistory',
      streams.address.uniqueHistory,
      (String? transaction) => transaction == null
          ? doNothing(/* initial state */)
          : handleHistory(transaction),
    );

    listen(
      'streams.client.connected',
      streams.client.connected,
      (bool connected) => connected ? handleBacklog() : doNothing(),
    );
  }

  void doNothing() {}

  Future handleHistory(String transaction) async {
    print('handling $transaction');
    if (await services.history.getTransactions([transaction])) {
      backlog.remove(transaction);
      await areWeAllDone();
    } else {
      print('adding to backlog!');
      backlog.add(transaction);
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
    if (backlog.isEmpty && streams.address.empty.value == true) {
      var done = await services.history.produceAddressOrBalance();
      if (done) {
        streams.address.empty.add(null);
      }
    }
  }
}
