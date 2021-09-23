import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SettingWaiter extends Waiter {
  void init() {
    listeners.add(settings.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              // will be initialized with settings set of settings
            },
            updated: (updated) {
              var setting = updated.data;
              if ([services.client.chosenDomain, services.client.chosenPort]
                  .contains(setting.name)) {
                ravenClientSubject.sink.add(null);
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
