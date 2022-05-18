import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'waiter.dart';

class AssetWaiter extends Waiter {
  void init() {
    listen(
      'assets.changes',
      res.assets.changes,
      (Change<Asset> change) => handleAddressChange(change),
    );
  }

  void handleAddressChange(Change<Asset> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) {
          /// only show message during normal run
          if (!services.wallet.leader.newLeaderProcessRunning) {
            streams.app.snack.add(
                Snack(message: 'New asset detected: ${added.data.symbol}'));
          }
        },
        updated: (updated) {},
        removed: (removed) {});
  }
}
