import 'package:raven/raven.dart';

Future initWaiters() async {
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



/*
issues:

1. should we be able to view add the addresses in an hd wallet? and their balances etc?
*/