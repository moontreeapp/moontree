import 'package:raven_back/raven_back.dart';

import 'waiter.dart';

class SettingWaiter extends Waiter {
  void init() {
    listen(
      'settings.batchedChanges',
      res.settings.batchedChanges,
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
                  streams.client.client.add(null);
                }
              },
              removed: (removed) {});
        });
      },
    );
  }
}
