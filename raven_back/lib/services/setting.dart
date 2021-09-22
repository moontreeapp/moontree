import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class SettingService {
// also used to start
  Future restartWaiters() async {
    deinitElectrumWaiters();
    deinitNonElectrumWaiters();
    var client = await initNonElectrumWaiters();
    initElectrumWaiters(client);
  }

  Future startWaiters() async {
    await restartWaiters();
  }

  void restartElectrumWaiters() {
    deinitElectrumWaiters();
    initElectrumWaiters(settingWaiter.client!);
  }

  Future<RavenElectrumClient> createClient() async {
    return await RavenElectrumClient.connect(
        settings.primaryIndex
            .getOne(SettingName.Electrum_Url)!
            .value, //source loaded? Unhandled Exception: Null check operator used on a null value
        port: settings.primaryIndex.getOne(SettingName.Electrum_Port)!.value);
  }
}
