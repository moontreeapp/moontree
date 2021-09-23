import 'package:raven/raven.dart';

Future initNonElectrumWaiters() async {
  balanceWaiter.init();
  accountWaiter.init();
  leaderWaiter.init();
  singleWaiter.init();
  addressWaiter.init();
  ravenClientWaiter.init();
  settingWaiter.init();
  addressSubscriptionWaiter.init();
  blockWaiter.init();
  // todo: don't kill app if this fails
  await rateWaiter.init();
}
