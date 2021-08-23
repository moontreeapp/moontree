import 'package:raven/init/reservoirs.dart';
import 'package:raven/init/services.dart';
import 'package:raven/waiters.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

AccountsWaiter? accountsWaiter;
LeadersWaiter? leadersWaiter;
SinglesWaiter? singlesWaiter;
AddressSubscriptionWaiter? addressSubscriptionWaiter;
AddressesWaiter? addressesWaiter;
AccountBalanceWaiter? accountBalanceWaiter;
ExchangeRateWaiter? exchangeRateWaiter;
SettingsWaiter? settingsWaiter;

void initNonElectrumWaiters() {
  accountsWaiter = AccountsWaiter(
    accounts,
    wallets,
    leaderWalletGenerationService,
  )..init();
  leadersWaiter = LeadersWaiter(
    wallets,
    addresses,
    leaderWalletDerivationService,
  )..init();
  singlesWaiter = SinglesWaiter(
    wallets,
    addresses,
    singleWalletService,
  )..init();
  addressesWaiter = AddressesWaiter(addresses, histories)..init();
  accountBalanceWaiter = AccountBalanceWaiter(
    histories,
    balanceService,
  )..init();
  exchangeRateWaiter = ExchangeRateWaiter(ratesService)..init();
  settingsWaiter = SettingsWaiter(settings, settingsService)..init();
}

void deinitElectrumWaiters() {
  addressSubscriptionWaiter?.deinit();
}

void deinitNonElectrumWaiters() {
  leadersWaiter?.deinit();
  singlesWaiter?.deinit();
  addressesWaiter?.deinit();
  accountBalanceWaiter?.deinit();
  exchangeRateWaiter?.deinit();
  settingsWaiter?.deinit();
}

void initElectrumWaiters(RavenElectrumClient client) {
  addressSubscriptionWaiter = AddressSubscriptionWaiter(
    addresses,
    client,
    addressSubscriptionService,
    leaderWalletDerivationService,
  )..init();
}
