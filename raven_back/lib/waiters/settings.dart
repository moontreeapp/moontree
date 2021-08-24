import 'package:reservoir/reservoir.dart';

import 'package:raven/records/setting_name.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/services.dart';

class SettingsWaiter extends Waiter {
  SettingReservoir settings;
  SettingService settingService;

  SettingsWaiter(this.settings, this.settingService) : super();

  @override
  void init() {
    listeners.add(settings.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              // will be initialized with settings set of settings
            },
            updated: (updated) {
              var setting = updated.data;
              if ([SettingName.Electrum_Url, SettingName.Electrum_Port]
                  .contains(setting.name)) {
                settingService.restartElectrumWaiters();
              }
            },
            removed: (removed) {});
      });
    }));
  }
}
