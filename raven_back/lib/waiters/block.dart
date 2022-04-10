/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class BlockWaiter extends Waiter {
  void init() {
    listen(
      'streams.client.client',
      streams.client.client,
      (RavenElectrumClient? ravenClient) async =>
          ravenClient != null ? subscribe(ravenClient) : () {},
    );
  }

  void subscribe(RavenElectrumClient ravenClient) {
    listen(
      'ravenClient.subscribeHeaders',
      ravenClient.subscribeHeaders(),
      (BlockHeader blockHeader) async =>
          await res.blocks.save(Block.fromBlockHeader(blockHeader)),
      autoDeinit: true,
    );

    // update existing mempool transactions each block
    listen<Change<Block>>(
      'blocks.changes',
      res.blocks.changes,
      (Change<Block> change) =>
          services.download.history.getAndSaveMempoolTransactions(),
      autoDeinit: true,
    );
  }
}
