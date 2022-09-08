/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'waiter.dart';

class DownloadWaiter extends Waiter {
  static const Duration queueTimer = Duration(seconds: 1);

  Set<Address> addresses = {};
  Address? address;

  void init() {
    listen(
      'streams.download.address',
      streams.download.address,
      (Address address) async => await addToQueue(address),
    );

    listen(
      'queueTimer',
      Stream.periodic(queueTimer),
      (_) async => await processQueue(),
    );
  }

  Future<void> processQueue() async {
    // todo: only process if idle.
    if (address != null || addresses.isEmpty) return;
    address = addresses.first;
    addresses.remove(address);
    await downloadAddress();
    address = null;
  }

  Future<void> addToQueue(Address address) async {
    addresses.add(address);
  }

  Future<void> downloadAddress() async {
    // download history
    await services.download.history.getTransactions(
      await services.download.history.getHistory(address!),
    );
    // Get dangling transactions
    await services.download.history.allDoneProcess();
  }
}
