import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/rate.dart';

void initWaiters(HiveLoadingStep step) {
  if ([HiveLoadingStep.All, HiveLoadingStep.Lock].contains(step)) {
    waiters.single.init();
    waiters.leader.init();
    waiters.password.init();
    waiters.setting.init();
    waiters.app.init();
    waiters.rate.init(RVNtoFiat());
  }
  if ([HiveLoadingStep.All, HiveLoadingStep.Login].contains(step)) {
    waiters.client.init();
    waiters.address.init();
    //waiters.asset.init();
    waiters.subscription.init();
    waiters.block.init();
    waiters.send.init();
    waiters.import.init();
    waiters.create.init();
    waiters.reissue.init();
  }
}
