import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SettingWaiter extends Waiter {
  RavenElectrumClient? client;

  Future init() async {
    // One-time initialization of Electrum Client at app start
    client = await services.settings.createClient();

    listeners.add(settings.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              // will be initialized with settings set of settings
            },
            updated: (updated) async {
              var setting = updated.data;
              if ([SettingName.Electrum_Url, SettingName.Electrum_Port]
                  .contains(setting.name)) {
                await client?.close();
                services.settings.restartElectrumWaiters(
                    client = await services.settings.createClient());
              }

              // When password changes, replace the cipher registry objects
              // TODO:
              //  1. bump the global password version (in settings)
              //  2. call initCiphersWithPassword
              //  3. migrate old passwords to new passwords
            },
            removed: (removed) {});
      });
    }));
  }
}
