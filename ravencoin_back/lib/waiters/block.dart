/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_back/waiters/waiter.dart';

class BlockWaiter extends Waiter {
  bool notify = true;
  void init() {
    listen('streams.client.connected', streams.client.connected,
        (ConnectionStatus connectionStatus) async {
      if (connectionStatus == ConnectionStatus.connected) {
        await subscribe();
        if (notify) {
          streams.app.snack.add(Snack(message: 'Successfully Connected'));
          notify = false;
        }
      }
    });
  }

  Future<void> subscribe() async {
    await listen(
      'ravenClient.subscribeHeaders',
      await services.client.api.subscribeHeaders(),
      (BlockHeader blockHeader) async {
        await pros.blocks.save(Block.fromBlockHeader(blockHeader));
      },
      autoDeinit: true,
    );

    // update existing mempool transactions each block
    await listen<Change<Block>>(
      'blocks.changes',
      pros.blocks.changes,
      (Change<Block> change) => change.when(
        loaded: (Loaded<Block> loaded) {},
        added: (Added<Block> added) async {
          await services.download.history.getAndSaveMempoolTransactions();
        },
        updated: (Updated<Block> updated) {},
        removed: (Removed<Block> removed) {},
      ),
      autoDeinit: true,
    );
  }
}
