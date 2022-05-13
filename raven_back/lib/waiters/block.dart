/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:raven_back/streams/client.dart';
import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class BlockWaiter extends Waiter {
  void init() {
    listen(
      'streams.client.connected',
      streams.client.connected,
      (ConnectionStatus connectionStatus) async =>
          connectionStatus == ConnectionStatus.connected
              ? await subscribe()
              : () {},
    );
  }

  Future<void> subscribe() async {
    await listen(
      'ravenClient.subscribeHeaders',
      await services.client.api.subscribeHeaders(),
      (BlockHeader blockHeader) async =>
          await res.blocks.save(Block.fromBlockHeader(blockHeader)),
      autoDeinit: true,
    );

    // update existing mempool transactions each block
    await listen<Change<Block>>(
      'blocks.changes',
      res.blocks.changes,
      (Change<Block> change) =>
          services.download.history.getAndSaveMempoolTransactions(),
      autoDeinit: true,
    );
  }
}
