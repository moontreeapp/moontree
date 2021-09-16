import 'package:test/test.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven/raven.dart';

void main() async {
  var hiveInit = HiveInitializer(destroyOnTeardown: true);

  setUp(() async {
    await hiveInit.setUp();
    settings.setSource(MapSource({
      '0': Setting(name: SettingName.Electrum_Url, value: 'testnet.rvn.rocks'),
      '1': Setting(name: SettingName.Electrum_Port, value: 50002),
    }));
    await settingsService.startWaiters();
  });

  tearDown(() async {
    await hiveInit.tearDown();
  });

  test('waiters listening', () async {
    for (var waiter in [
      addressSubscriptionWaiter,
      blockSubscriptionWaiter,
      walletBalanceWaiter,
      accountsWaiter,
      leadersWaiter,
      singlesWaiter,
      addressesWaiter,
      // exchangeRateWaiter,
      settingsWaiter
    ]) {
      expect(waiter.listeners.isNotEmpty, true,
          reason: '${waiter.runtimeType} has no listeners');
    }
  });
}
