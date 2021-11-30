import 'package:test/test.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven_back/raven_back.dart';

void main() async {
  var hiveInit = HiveInitializer(destroyOnTeardown: true);

  setUp(() async {
    await hiveInit.setUp();
    settings.setSource(MapSource({
      '0': Setting(
          name: SettingName.Electrum_Domain0, value: 'testnet.rvn.rocks'),
      '1': Setting(name: SettingName.Electrum_Port0, value: 50002),
    }));
    await services.settings.startWaiters();
  });

  tearDown(() async {
    await hiveInit.tearDown();
  });

  test('waiters listening', () async {
    for (var waiter in [
      addressSubscriptionWaiter,
      blockWaiter,
      accountWaiter,
      leaderWaiter,
      singleWaiter,
      addressWaiter,
      // exchangeRateWaiter,
      settingWaiter
    ]) {
      expect(waiter.listeners.isNotEmpty, true,
          reason: '${waiter.runtimeType} has no listeners');
    }
  });
}
