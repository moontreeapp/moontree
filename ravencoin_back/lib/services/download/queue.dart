import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';

class QueueService {
  Set<Address> addresses = {};
  Address? address;

  static const Duration queueTimer = Duration(seconds: 1);
  StreamSubscription? periodic;

  void retry() => periodic == null
      ? periodic =
          Stream.periodic(queueTimer).listen((_) async => await process())
      : () {};

  Future reset() async {
    await periodic?.cancel();
    periodic = null;
  }

  Future<void> update(Address address) async {
    addresses.add(address);
    await process();
  }

  Future<void> process() async {
    // todo: only process if idle.
    if (addresses.isEmpty) {
      await reset();
    }
    if (address != null ||
        services.client.subscribe.startupProcessRunning ||
        services.wallet.leader.newLeaderProcessRunning ||
        services.download.history.busy) {
      retry();
      return;
    }
    address = addresses.first;
    addresses.remove(address);
    await downloadAddress();
  }

  Future<void> downloadAddress() async {
    // download history
    await services.download.history.getTransactions(
      await services.download.history.getHistory(address!),
    );
    if (addresses.isEmpty) {
      // Get dangling transactions
      await services.download.history.allDoneProcess();
      await reset();
    } else {
      address = null;
      await process();
    }
  }
}
