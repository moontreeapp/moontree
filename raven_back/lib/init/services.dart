import 'package:raven/init/reservoirs.dart';
import 'package:raven/services.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

AddressDerivationService? addressDerivationService;
AddressSubscriptionService? addressSubscriptionService;
AddressesService? addressesService;
AccountBalanceService? accountBalanceService;
ExchangeRateService? conversionRateService;

void initServices(RavenElectrumClient client) {
  addressDerivationService =
      AddressDerivationService(wallets, addresses, histories)..init();
  addressSubscriptionService = AddressSubscriptionService(
      wallets, addresses, histories, client, addressDerivationService!)
    ..init();
  addressesService = AddressesService(accounts, wallets, addresses, histories)
    ..init();
  accountBalanceService = AccountBalanceService(accounts, balances, histories)
    ..init();
  conversionRateService = ExchangeRateService(balances, rates)..init();
}

void deinitServices() {
  addressDerivationService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
  accountBalanceService?.deinit();
  conversionRateService?.deinit();
}
