import 'package:raven/init.dart';
import 'package:raven/records/setting_name.dart';
import 'package:raven/services/service.dart';
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class SettingService extends Service {
  late final SettingReservoir settings;

  SettingService(this.settings) : super();

  Future saveSetting(SettingName name, value) async {
    await settings.save(Setting(name: name, value: value));
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
        settings.primaryIndex
            .getOne(SettingName.Electrum_Url)!
            .value, //source loaded? Unhandled Exception: Null check operator used on a null value
        port: settings.primaryIndex.getOne(SettingName.Electrum_Port)!.value);
  }
}
