import 'package:client_back/utilities/rate.dart';
import 'package:test/test.dart';

import 'package:proclaim/map_source.dart';
import 'package:client_back/client_back.dart';

void main() async {
  var hiveInit = HiveInitializer(destroyOnTeardown: true);

  setUp(() async {
    await hiveInit.setUp(HiveLoadingStep.all);
    pros.settings.setSource(MapSource({
      '0': const Setting(
          name: SettingName.electrum_domain, value: 'testnet.rvn.rocks'),
      '1': const Setting(name: SettingName.electrum_port, value: 50002),
    }));

    triggers.leader.init();
    triggers.single.init();
    triggers.address.init();
    triggers.client.init();
    //triggers.setting.init();
    triggers.subscription.init();
    triggers.block.init();
    triggers.send.init();
    triggers.import.init();
    triggers.rate.init(RVNtoFiat());
  });

  tearDown(() async {
    await hiveInit.tearDown();
  });

  test('triggers listening', () async {
    for (var waiter in [
      triggers.subscription,
      triggers.block,
      triggers.leader,
      triggers.single,
      triggers.address,
      //triggers.setting
    ]) {
      expect(waiter.listeners.isNotEmpty, true,
          reason: '${waiter.runtimeType} has no listeners');
    }
  });
}
