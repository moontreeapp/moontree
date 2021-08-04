import 'package:raven/init/reservoirs.dart';
import 'package:raven/services/address_derivation.dart';
import 'package:raven/services/address_subscription.dart';
import 'package:raven/services/addresses.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

AddressDerivationService? addressDerivationService;
AddressSubscriptionService? addressSubscriptionService;
AddressesService? addressesService;

void initServices(RavenElectrumClient client) {
  addressDerivationService =
      AddressDerivationService(accounts, addresses, histories)..init();
  addressSubscriptionService = AddressSubscriptionService(
      accounts, addresses, histories, client, addressDerivationService!)
    ..init();
  addressesService = AddressesService(accounts, addresses, histories)..init();
}

void deinitServices() {
  addressDerivationService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
}
