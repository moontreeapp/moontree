import 'package:raven_back/raven_back.dart';

Future initWaiters(HiveLoadingStep step) async {
  if ([HiveLoadingStep.All, HiveLoadingStep.Lock].contains(step)) {
    waiters.single.init();
    waiters.leader.init();
    waiters.password.init();
    waiters.setting.init();
    waiters.app.init();
    await waiters.rate.init();
  }
  if ([HiveLoadingStep.All, HiveLoadingStep.Login].contains(step)) {
    waiters.client.init();
    waiters.address.init();
    waiters.asset.init();
    waiters.subscription.init();
    waiters.block.init();
    waiters.send.init();
    waiters.import.init();
    waiters.create.init();
    waiters.reissue.init();
  }
}
