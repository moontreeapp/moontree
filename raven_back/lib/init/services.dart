import 'package:raven/init/reservoirs.dart';
import 'package:raven/services.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

LeadersService? leadersService;
SinglesService? singlesService;
AddressSubscriptionService? addressSubscriptionService;
AddressesService? addressesService;
AccountBalanceService? accountBalanceService;
ExchangeRateService? exchangeRateService;

void initServices(RavenElectrumClient client) {
  leadersService = LeadersService(wallets, addresses)..init();
  singlesService = SinglesService(wallets, addresses)..init();
  addressSubscriptionService = AddressSubscriptionService(
    addresses,
    client,
  )..init();
  addressesService = AddressesService(addresses, histories)..init();
  accountBalanceService = AccountBalanceService(histories)..init();
  exchangeRateService = ExchangeRateService()..init();
}

void deinitServices() {
  leadersService?.deinit();
  singlesService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
  accountBalanceService?.deinit();
  exchangeRateService?.deinit();
}
