import 'package:test/test.dart';

import 'package:reservoir/map_source.dart';
import 'package:raven_back/raven_back.dart';

void main() async {
  var hiveInit = HiveInitializer(destroyOnTeardown: true);

  setUp(() async {
    await hiveInit.setUp();
    res.settings.setSource(MapSource({
      '0': Setting(
          name: SettingName.Electrum_Domain0, value: 'testnet.rvn.rocks'),
      '1': Setting(name: SettingName.Electrum_Port0, value: 50002),
    }));
    //await services.settings.startWaiters(); // really old
  });

  tearDown(() async {
    await hiveInit.tearDown();
  });

  test('waiters listening', () async {
    for (var waiter in [
      waiters.subscription,
      waiters.block,
      waiters.account,
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
