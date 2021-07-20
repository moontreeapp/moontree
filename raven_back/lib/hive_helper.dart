import 'package:hive/hive.dart';
import 'models/adapters.dart';

class HiveHelper {
  static Future init() async {
    registerAdapters();
    try {
      await open();
    } on HiveError {
      throw StateError(
          'Call Hive.init() or Hive.initFlutter() before HiveHelper.init()');
    }
  }

  static void registerAdapters() {
    Hive.registerAdapter(AccountStoredAdapter());
    Hive.registerAdapter(HDNodeAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(ScripthashUnspentAdapter());
    Hive.registerAdapter(ScripthashHistoryAdapter());
    Hive.registerAdapter(ScripthashBalanceAdapter());
  }

  static Future open() async {
    await Hive.openBox('settings');
    await Hive.openBox('accounts');
    await Hive.openBox('scripthashAccountIdInternal');
    await Hive.openBox('scripthashAccountIdExternal');
    await Hive.openBox('scripthashOrderInternal');
    await Hive.openBox('scripthashOrderExternal');
    await Hive.openBox('balances');
    await Hive.openBox('histories');
    await Hive.openBox('unspents');
    await Hive.openBox('accountUnspents');
  }

  static Future close() async {
    await Hive.close();
  }
}
