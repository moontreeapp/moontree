import 'package:hive/hive.dart';
import 'records.dart';

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
    // finish...
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(BalanceAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(NetAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
  }

  static Future open() async {
    await Hive.openBox('settings');
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');

    /* replaced by reports ... */
    await Hive.openBox('balances');
    await Hive.openBox('histories');
    await Hive.openBox('unspents');
    /* ... */
  }

  static Future close() async {
    await Hive.close();
  }
}
