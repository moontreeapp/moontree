import 'package:raven/init/reservoirs.dart';
import 'package:raven/init/waiters.dart';
import 'package:raven/services.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

LeadersService? leadersService;
SinglesService? singlesService;
AddressSubscriptionService? addressSubscriptionService;
AddressesService? addressesService;
AccountBalanceService? accountBalanceService;
ExchangeRateService? exchangeRateService;

void initServices(RavenElectrumClient client) {
  leadersService = LeadersService(
    wallets,
    addresses,
    leaderWalletDerivationWaiter,
  )..init();
  singlesService = SinglesService(
    wallets,
    addresses,
    singleWalletWaiter,
  )..init();
  addressSubscriptionService = AddressSubscriptionService(
    addresses,
    client,
    addressSubscriptionWaiter,
    leaderWalletDerivationWaiter,
  )..init();
  addressesService = AddressesService(addresses, histories)..init();
  accountBalanceService = AccountBalanceService(
    histories,
    balanceWaiter,
  )..init();
  exchangeRateService = ExchangeRateService(ratesWaiter)..init();
}

void deinitServices() {
  leadersService?.deinit();
  singlesService?.deinit();
  addressSubscriptionService?.deinit();
  addressesService?.deinit();
  accountBalanceService?.deinit();
  exchangeRateService?.deinit();
}
