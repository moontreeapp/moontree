import 'package:raven_back/raven_back.dart';

Future initWaiters() async {
  // The following waiters must be inited before HiveInitializer.load()
  //waiters.account.init();

  waiters.leader.init();
  waiters.single.init();
  waiters.address.init();
  waiters.ravenClient.init();
  waiters.setting.init();
  waiters.addressSubscription.init();
  waiters.block.init();
  waiters.send.init();
  waiters.import.init();
  waiters.password.init();
  // todo: don't kill app if this fails
  await waiters.rate.init();
}



/*
issues:

1. should we be able to view add the addresses in an hd wallet? and their balances etc?
*/