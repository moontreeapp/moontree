import 'package:test/test.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven_back/raven_back.dart';

void main() async {
  var hiveInit = HiveInitializer(destroyOnTeardown: true);

  setUp(() async {
    await hiveInit.setUp();
    res.settings.setSource(MapSource({
      '0': Setting(
          name: SettingName.Electrum_Domain, value: 'testnet.rvn.rocks'),
      '1': Setting(name: SettingName.Electrum_Port, value: 50002),
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
    waiters.password.init();
    await waiters.rate.init();
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
