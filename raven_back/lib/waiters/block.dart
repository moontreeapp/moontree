/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class BlockWaiter extends Waiter {
  void init() {
    listen('streams.client.client', streams.client.client, (ravenClient) async {
      if (ravenClient != null) {
        subscribe(ravenClient as RavenElectrumClient);
      }
    });
  }

  void subscribe(RavenElectrumClient ravenClient) {
    listen(
      'ravenClient.subscribeHeaders',
      ravenClient.subscribeHeaders(),
      (blockHeader) async =>
          await blocks.save(Block.fromBlockHeader(blockHeader! as BlockHeader)),
      autoDeinit: true,
    );

    // update existing mempool transactions each block
    listen<Change<Block>>(
      'blocks.changes',
      blocks.changes,
      (change) {
        services.address.getAndSaveMempoolTransactions();
      },
      autoDeinit: true,
    );
  }
}
