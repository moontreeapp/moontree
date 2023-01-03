/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class BlockWaiter extends Trigger {
  bool notify = true;
  void init() {
    when(
        thereIsA: streams.client.connected.where(
            (ConnectionStatus connectionStatus) =>
                connectionStatus == ConnectionStatus.connected),
        doThis: subscribeAndNotify);
  }

  Future<void> subscribeAndNotify(ConnectionStatus _) async {
    await subscribe();
    if (notify) {
      streams.app.snack.add(Snack(message: 'Successfully Connected'));
      notify = false;
    }
  }

  Future<void> subscribe() async {
    await when(
      thereIsA: await services.client.api.subscribeHeaders(),
      doThis: (BlockHeader blockHeader) async {
        await pros.blocks.save(Block.fromBlockHeader(blockHeader));
      },
      autoDeinit: true,
      // key should be specified because different chains give different keys by
      // default so autoDeinit never gets triggered
      key: 'block height',
    );

    // update existing mempool transactions each block
    await when<Change<Block>>(
      thereIsA: pros.blocks.changes,
      doThis: (Change<Block> change) => change.when(
        loaded: (Loaded<Block> loaded) {},
        added: (Added<Block> added) async {
          await services.download.history.getAndSaveMempoolTransactions();
        },
        updated: (Updated<Block> updated) {},
        removed: (Removed<Block> removed) {},
      ),
      autoDeinit: true,
      // key should be specified because different chains give different keys by
      // default so autoDeinit never gets triggered
      key: 'mempool getter',
    );
  }
}
