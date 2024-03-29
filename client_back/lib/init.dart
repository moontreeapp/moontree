import 'package:client_back/client_back.dart';
import 'package:client_back/utilities/rate.dart';

void initTriggers(HiveLoadingStep step) {
  if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.lock]
      .contains(step)) {
    //triggers.single.init();
    //triggers.leader.init();
    ////triggers.setting.init();
    triggers.app.init();
    triggers.rate.init(RVNtoFiat());
  }
  if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.login]
      .contains(step)) {
    //triggers.client.init();
    //triggers.address.init();
    ////triggers.asset.init();
    //triggers.subscription.init();
    //triggers.block.init();
    //triggers.send.init();
    //triggers.create.init();
    //triggers.reissue.init();
    //triggers.unspent.init();
  }
}
