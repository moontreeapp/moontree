/// init process:
/// make reservoirs
///   load all records into reservoirs
/// set up listener on electrum settings
///   stop services
///   start services (contains listeners on all reservoirs)
import 'package:raven/init/reservoirs.dart';
import 'package:raven/init/waiters.dart';
import 'package:raven/init/services.dart';
import 'package:raven/subjects/settings.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

void init() {
  makeReservoirs();
  makeServices();
  electrumSettingsStream(settings).listen(handleListening);
  // if reservoirs are empty -> startup first time process

  /** on startup
   * start hive
   * init this
   * (flutter) if no accounts -> create account, set default account setting
   * ...(raven listener) created account, empty -> create wallet...
   * ...(listener) created wallet, empty -> create address...
   */

  /** long term triggers...
   * if balance > x and seed phrase not saved-> give warning let them write seed
   * if not used password recently -> use (ignore)
   * if not changed password recently -> refresh
   */
}

Stream electrumSettingsStream(settings) {
  return settings
      .map((s) => {
            'url': s['electrum.url'],
            'port': s['electrum.port'],
          })
      .distinct();
}

Future handleListening(electrumSetting) async {
  deinitWaiters();
  initWaiters(await RavenElectrumClient.connect(
      electrumSetting['url'] ?? 'testnet.rvn.rocks',
      port: electrumSetting['port'] ?? 50002));
}
