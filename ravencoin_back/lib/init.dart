import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/rate.dart';

void initWaiters(HiveLoadingStep step) {
  if ([HiveLoadingStep.all, HiveLoadingStep.lock].contains(step)) {
    waiters.single.init();
    waiters.leader.init();
    waiters.setting.init();
    waiters.app.init();
    waiters.rate.init(RVNtoFiat());
  }
  if ([HiveLoadingStep.all, HiveLoadingStep.login].contains(step)) {
    waiters.client.init();
    waiters.address.init();
    //waiters.asset.init();
    waiters.subscription.init();
    waiters.block.init();
    waiters.send.init();
    waiters.import.init();
    waiters.create.init();
    waiters.reissue.init();
    waiters.unspent.init();
  }
}
