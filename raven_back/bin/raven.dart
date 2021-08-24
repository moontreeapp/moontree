import 'package:hive/hive.dart';
import 'package:raven/init/hive_helper.dart';

void main() async {
  // Initialize Hive
  Hive.init('database');
  await HiveHelper.init();

  try {
    var box = Hive.box('settings');
    await box.put('server', 'testnet.rvn.rocks');
    await box.put('port', 50002);
    await Future.delayed(Duration(milliseconds: 200));
    await box.put('server', 'wrong.server');

    await Future.delayed(Duration(milliseconds: 500));
    await box.put('server', 'testnet.rvn.rocks');
  } finally {
    await HiveHelper.close();
  }
}
