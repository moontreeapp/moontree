import 'package:raven_back/raven_back.dart';

Future initWaiters() async {
  waiters.leader.init();
  waiters.single.init();
  waiters.address.init();
  waiters.client.init();
  waiters.setting.init();
  waiters.subscription.init();
  waiters.block.init();
  waiters.send.init();
  waiters.import.init();
  waiters.password.init();
  waiters.create.init();
  waiters.reissue.init();
  await waiters.rate.init();
}
