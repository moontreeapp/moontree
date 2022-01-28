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
    for (var transaction in transactions) {
      if ([
        '681c62266f6dc3c1c16ba5024c5bb875c627ab89815fd61f689519e06036832b',
        'f585233ccb19f93912c094e66d5681b73a4adcf3db50c7455e5d9b2a724b2345',
        '47f0fc510a930c56797d5bf2ed574e9a7d67153d8e34e6b342af6947d0efdddf',
        'e80568e961b4a978dcf5ab533638505823bbb83bbea2c742afb35f6b22ff96b6',
        'c512010a793a7a4296e1a34e1c11b94441226f602cf57c9b56d3a20307f02b41',
        'fe08c278ad54f3fdcc35aa6d05de7b955f22d842d9ef75a501fa82aa68dbc178',
        '00111be079656f15bc63afa843860f37e0ecbc6e374c2e35c11fac6eff9cb810',
        '5fd5dc8fbb486404feb24762a838c09131d225b3547b9fa318920d1593591139',
        'ef1be6f06025e6bd8d7e8319003296e168068ce9d08e6efc1612c06fcb13c330',
        '14de222d2825ec8e187e4d8c2785bdf26663d6d8e9f5475cb97a5e6376a64d56',
        '24031e0a46ae015cdb58d53dfb8910207d53b6a061387ffd2368730533043f3e',
        '6b5d00227fc75b590d693877a32ecce55664fd851238de1cfa3fae5ce1362862',
        '17b798480e340ae639c23a036ee39d61784b4418ca3d40c43ae2e7c9728e76e2',
        '6ef14bbacb9dc343eb9cde1f2a311ae787231613fc6ae863cec11752a56c3308',
        '53572c6054e8c00b847ed19682e487b1a44b4a28c3a6001bd84473db1c671044',
        '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
        '7217229e9fa0e668aebc4d1478ab69320ee7d9b6ca6357c30a38b4b4a89a0c0d',
        'c88fe87a5df1f8fac0ba929a7021038d66947fd4aabef2368eb7aa21aea2c3c5',
        '9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
      ].contains(transaction.txHash)) {
        print('getting ${transaction.txHash}');
      }
    }
    if (await services.history.getTransactions(transactions)) {
      backlog.removeAll(transactions);
      await areWeAllDone();
    } else {
      print('adding to backlog!');
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
    if (backlog.isEmpty && streams.address.empty.value == true) {
      var done = await services.history.produceAddressOrBalance();
      if (done) {
        streams.address.empty.add(null);
      }
    }
  }
}
