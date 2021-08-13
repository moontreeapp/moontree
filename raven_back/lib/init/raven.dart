/// init process:
/// make reservoirs
///   load all records into reservoirs
/// set up listener on electrum settings
///   stop services
///   start services (contains listeners on all reservoirs)
import 'package:raven/init/stewards.dart';
import 'package:raven/init/reservoirs.dart';
import 'package:raven/init/services.dart';
import 'package:raven/subjects/settings.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

void init() {
  makeStewards();
  makeReservoirs();
  fillReservoirsSteward(
    accounts,
    addresses,
    histories,
    wallets,
    balances,
    rates,
  );
  // if reservoirs are empty -> startup first time process
  electrumSettingsStream(settings).listen(handleListening);
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
  deinitServices();
  initServices(await RavenElectrumClient.connect(
      electrumSetting['url'] ?? 'testnet.rvn.rocks',
      port: electrumSetting['port'] ?? 50002));
  fillServicesSteward(
    leadersService,
    singlesService,
    addressSubscriptionService,
    addressesService,
    accountBalanceService,
    exchangeRateService,
  );
}
