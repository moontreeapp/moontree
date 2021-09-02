import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'globals.dart';

void initNonElectrumWaiters() {
  accountsWaiter.init();
  leadersWaiter.init();
  singlesWaiter.init();
  addressesWaiter.init();
  accountBalanceWaiter.init();
  exchangeRateWaiter.init();
  settingsWaiter.init();
}

void deinitElectrumWaiters() {
  addressSubscriptionWaiter.deinit();
  //blockSubscriptionWaiter.deinit();
}

void deinitNonElectrumWaiters() {
  leadersWaiter.deinit();
  singlesWaiter.deinit();
  addressesWaiter.deinit();
  accountBalanceWaiter.deinit();
  exchangeRateWaiter.deinit();
  settingsWaiter.deinit();
}

void initElectrumWaiters(RavenElectrumClient client) {
  addressSubscriptionWaiter.init(client);
  //blockSubscriptionWaiter.init(client);
}

Future init() async {
  await settingsService.startWaiters();
}
