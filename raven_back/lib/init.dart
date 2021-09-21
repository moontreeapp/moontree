import 'package:raven_electrum_client/raven_electrum_client.dart';

//import 'globals.dart';
import 'package:raven/raven.dart';

Future<RavenElectrumClient> initNonElectrumWaiters() async {
  balanceWaiter.init();
  accountWaiter.init();
  leaderWaiter.init();
  singleWaiter.init();
  addressWaiter.init();
  await rateWaiter.init();
  await settingWaiter.init();
  return settingWaiter.client!;
}

void deinitElectrumWaiters() {
  addressSubscriptionWaiter.deinit();
  blockWaiter.deinit();
}

void deinitNonElectrumWaiters() {
  balanceWaiter.deinit();
  leaderWaiter.deinit();
  singleWaiter.deinit();
  addressWaiter.deinit();
  rateWaiter.deinit();
  settingWaiter.deinit();
}

void initElectrumWaiters(RavenElectrumClient client) {
  addressSubscriptionWaiter.init(client);
  blockWaiter.init(client);
}

Future initWaiters() async {
  await services.settings.startWaiters();
}
