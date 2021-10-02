import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SettingWaiter extends Waiter {
  void init() {
    if (!listeners.keys.contains('settings.changes')) {
      listeners['settings.changes'] =
          settings.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(
              added: (added) {
                // will be initialized with settings set of settings
              },
              updated: (updated) {
                var setting = updated.data;
                if ([services.client.chosenDomain, services.client.chosenPort]
                    .contains(setting.name)) {
                  subjects.client.sink.add(null);
                }
              },
              removed: (removed) {});
        });
      });
    }
  }
}
