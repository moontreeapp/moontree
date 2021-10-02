import 'package:raven/raven.dart';

Future initWaiters() async {
  // should these be inited here? or just by the client / ciphers or whatever they depend on becoming avialable?
  // here: we gotta set up the listeners for them somewhere, probably not in construction of the object.
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