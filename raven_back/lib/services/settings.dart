import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class SettingService {
// also used to start
  void restartWaiters(RavenElectrumClient client) {
    deinitElectrumWaiters();
    deinitNonElectrumWaiters();
    initNonElectrumWaiters();
    initElectrumWaiters(client);
  }

  void startWaiters(RavenElectrumClient client) {
    restartWaiters(client);
  }

  void restartElectrumWaiters(RavenElectrumClient client) {
    deinitElectrumWaiters();
    initElectrumWaiters(client);
  }

  Future<RavenElectrumClient> createClient() async {
    return await RavenElectrumClient.connect(
        settings.primaryIndex
            .getOne(SettingName.Electrum_Url)!
            .value, //source loaded? Unhandled Exception: Null check operator used on a null value
        port: settings.primaryIndex.getOne(SettingName.Electrum_Port)!.value);
  }
}
