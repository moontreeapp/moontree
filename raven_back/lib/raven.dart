import 'package:raven/reservoirs.dart';
import 'package:raven/services/address_derivation.dart';
import 'package:raven/services/address_subscription.dart';
import 'package:raven/services/addresses.dart';
import 'package:raven/subjects/settings.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

AddressDerivationService? addressDerivationService;
AddressSubscriptionService? addressSubscriptionService;
AddressesService? addressesService;

void init() {
  makeReservoirs();
  electrumSettingsStream(settings).listen(handleListening);
}

Stream electrumSettingsStream(settings) {
  return settings
      .map((s) =>
          [s['electrum.url'], s['electrum.port']]) // testnet.rvn.rocks:50002
      .distinct();
}

Future handleListening(element) async {
  var client = await generateClient(element[0], element[1]);
  deinitServices();
  initServices(client);
}

Future generateClient(String url, [int port = 50002]) async {
  return await RavenElectrumClient.connect(url, port: port);
}

void deinitServices() {
  addressDerivationService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
}

void initServices(RavenElectrumClient client) {
  addressDerivationService =
      AddressDerivationService(accounts, addresses, histories)..init();
  addressSubscriptionService = AddressSubscriptionService(
      accounts, addresses, histories, client, addressDerivationService!)
    ..init();
  addressesService = AddressesService(accounts, addresses, histories)..init();
}
