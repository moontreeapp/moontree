import 'package:raven/init/waiters.dart';
import 'package:raven/records/setting_name.dart';
import 'package:raven/services/service.dart';
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class SettingService extends Service {
  late final SettingReservoir settings;

  SettingService(this.settings) : super();

  void saveSetting(name, value) {
    settings.save(Setting(name: name, value: value));
  }

  // also used to start
  Future restartWaiters() async {
    deinitElectrumWaiters();
    deinitNonElectrumWaiters();
    initNonElectrumWaiters();
    initElectrumWaiters(await createClient());
  }

  Future startWaiters() async {
    await restartWaiters();
  }

  Future restartElectrumWaiters() async {
    deinitElectrumWaiters();
    initElectrumWaiters(await createClient());
  }

  Future<RavenElectrumClient> createClient() async {
    return await RavenElectrumClient.connect(
        settings.get(SettingName.Electrum_Url)!.value,
        port: settings.get(SettingName.Electrum_Port)!.value);
  }
}
