import 'dart:html';

import 'package:quiver/iterables.dart';
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
  settings
      .map((s) =>
          [s['electrum.url'], s['electrum.port']]) // testnet.rvn.rocks:50002
      .distinct()
      .listen(handleListening);
}

Future handleListening(element) async {
  var client = await RavenElectrumClient.connect(element[0], port: element[1]);
  deinitServices();
  initServices(client);
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
  addressesService = AddressesService(accounts, addresses)..init();
}
