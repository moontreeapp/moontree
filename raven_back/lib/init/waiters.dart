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

void initWaiters(RavenElectrumClient client) {
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
  addressSubscriptionWaiter = AddressSubscriptionWaiter(
    addresses,
    client,
    addressSubscriptionService,
    leaderWalletDerivationService,
  )..init();
  addressesWaiter = AddressesWaiter(addresses, histories)..init();
  accountBalanceWaiter = AccountBalanceWaiter(
    histories,
    balanceService,
  )..init();
  exchangeRateWaiter = ExchangeRateWaiter(ratesService)..init();
}

void deinitWaiters() {
  leadersWaiter?.deinit();
  singlesWaiter?.deinit();
  addressSubscriptionWaiter?.deinit();
  addressesWaiter?.deinit();
  accountBalanceWaiter?.deinit();
  exchangeRateWaiter?.deinit();
}
