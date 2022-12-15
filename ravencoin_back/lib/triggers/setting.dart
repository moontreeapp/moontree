import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class SettingWaiter extends Trigger {
  void init() {
    /** simplified version below, you could use this version and then say, 
     * intead of foreach, you say, if any, that way you reconnect only once.
     * but since this is implemented for that, the simpler version below is
     * preferred.
    when(
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
                var setting = updated.record;
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

    /// removed because we want more control over when we reconnect
    //when(
    //    'settings.changes.electrum',
    //    pros.settings.changes.where((change) =>
    //        (change is Added || change is Updated) &&
    //        [
    //          //SettingName.Electrum_Net,
    //          SettingName.Electrum_Domain,
    //          SettingName.Electrum_Port,
    //          SettingName.Electrum_DomainTest,
    //          SettingName.Electrum_PortTest,
    //        ].contains(change.record.name)),
    //    (_) => services.client.createClient());

    /// to reduce listener bloat, this has been added on the function called to
    /// set the value in services.downloads.queue
    //when(
    //    'settings.changes.download',
    //    pros.settings.changes.where((change) =>
    //        (change is Added || change is Updated) &&
    //        [
    //          SettingName.No_History,
    //        ].contains(change.record.name)),
    //    (_) => services.download.queue.process());
  }
}
