/// this waiter is kind of pointless, because we want a message on every
/// received not just if a new asset was received

import 'package:client_back/client_back.dart';
//import 'package:client_back/streams/app.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class AssetWaiter extends Trigger {
  void init() {
    when(
      thereIsA: pros.assets.changes,
      doThis: handleAddressChange,
    );
  }

  void handleAddressChange(Change<Asset> change) {
    change.when(
        loaded: (Loaded<Asset> loaded) {},
        added: (Added<Asset> added) {
          /// only show message during normal run
          if (!services.wallet.leader.newLeaderProcessRunning) {
            /// we should show a message on every received not just a new asset
            //streams.app.snack.add(
            //    Snack(message: 'New asset detected: ${added.data.symbol}'));
          }
        },
        updated: (Updated<Asset> updated) {},
        removed: (Removed<Asset> removed) {});
  }
}
