import 'package:ravencoin_back/utilities/rate.dart';
import 'package:test/test.dart';

import 'package:proclaim/map_source.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

void main() async {
  var hiveInit = HiveInitializer(destroyOnTeardown: true);

  setUp(() async {
    await hiveInit.setUp(HiveLoadingStep.all);
    pros.settings.setSource(MapSource({
      '0': const Setting(
          name: SettingName.electrum_domain, value: 'testnet.rvn.rocks'),
      '1': const Setting(name: SettingName.electrum_port, value: 50002),
    }));

    waiters.leader.init();
    waiters.single.init();
    waiters.address.init();
    waiters.client.init();
    waiters.setting.init();
    waiters.subscription.init();
    waiters.block.init();
    waiters.send.init();
    waiters.import.init();
    waiters.rate.init(RVNtoFiat());
  });

  tearDown(() async {
    await hiveInit.tearDown();
  });

  test('waiters listening', () async {
    for (var waiter in [
      waiters.subscription,
      waiters.block,
      waiters.leader,
      waiters.single,
      waiters.address,
      // waiters.exchangeRate,
      waiters.setting
    ]) {
      expect(waiter.listeners.isNotEmpty, true,
          reason: '${waiter.runtimeType} has no listeners');
    }
  });
}
