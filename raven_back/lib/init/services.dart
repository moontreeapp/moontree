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
      AddressDerivationService(wallets, addresses, histories)..init();
  addressSubscriptionService = AddressSubscriptionService(
      wallets, addresses, histories, client, addressDerivationService!)
    ..init();
  addressesService = AddressesService(wallets, addresses, histories)..init();
}

void deinitServices() {
  addressDerivationService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
}
