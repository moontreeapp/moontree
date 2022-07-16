import 'package:ravencoin_back/ravencoin_back.dart';

import 'waiter.dart';

class SettingWaiter extends Waiter {
  void init() {
    /** simplified version below, you could use this version and then say, 
     * intead of foreach, you say, if any, that way you reconnect only once.
     * but since this is implemented for that, the simpler version below is
     * preferred.
    listen(
      'settings.batchedChanges',
      pros.settings.batchedChanges,
      (List<Change<Setting>> batchedChanges) {
        batchedChanges.forEach((change) {
          change.when(
              loaded: (loaded) {},
              added: (added) {
                // will be initialized with settings set of settings
              },
              updated: (updated) {
                var setting = updated.data;
                if ([
                  SettingName.Electrum_Net,
                  SettingName.Electrum_Domain,
                  SettingName.Electrum_Port,
                  SettingName.Electrum_DomainTest,
                  SettingName.Electrum_PortTest,
                ].contains(setting.name)) {
                  services.client.createClient();
                }
              },
              removed: (removed) {});
        });
      },
    );
    */

    listen(
        'settings.changes',
        pros.settings.changes.where((change) =>
            (change is Added || change is Updated) &&
            [
              SettingName.Electrum_Net,
              SettingName.Electrum_Domain,
              SettingName.Electrum_Port,
              SettingName.Electrum_DomainTest,
              SettingName.Electrum_PortTest,
            ].contains(change.data.name)),
        (_) => services.client.createClient());
  }
}
