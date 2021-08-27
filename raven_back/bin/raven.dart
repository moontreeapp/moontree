import 'package:hive/hive.dart';
import 'package:raven/init/hive_initializer.dart';
import 'package:raven/records.dart';
import 'package:raven/records/setting.dart';

var hiveInit = HiveInitializer(destroyOnTeardown: true);

void main() async {
  await hiveInit.setUp();

  try {
    var box = Hive.box<Setting>('settings');
    await box.put(
      'server',
      Setting(name: SettingName.Electrum_Url, value: 'testnet.rvn.rocks'),
    );
    await box.put(
      'port',
      Setting(name: SettingName.Electrum_Port, value: 50002),
    );
  } finally {
    await hiveInit.tearDown();
  }
}
