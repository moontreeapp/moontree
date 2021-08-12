import 'package:raven/init/reservoirs.dart';
import 'package:raven/services.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

AddressDerivationService? addressDerivationService;
AddressSubscriptionService? addressSubscriptionService;
AddressesService? addressesService;
AccountBalanceService? accountBalanceService;
ExchangeRateService? exchangeRateService;

void initServices(RavenElectrumClient client) {
  addressDerivationService =
      AddressDerivationService(leaders, addresses, histories)..init();
  addressSubscriptionService = AddressSubscriptionService(
      leaders, addresses, histories, client, addressDerivationService!)
    ..init();
  addressesService = AddressesService(accounts, leaders, addresses, histories)
    ..init();
  accountBalanceService = AccountBalanceService(accounts, balances, histories)
    ..init();
  exchangeRateService = ExchangeRateService(balances, rates)..init();
}

void deinitServices() {
  addressDerivationService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
  accountBalanceService?.deinit();
  exchangeRateService?.deinit();
}
