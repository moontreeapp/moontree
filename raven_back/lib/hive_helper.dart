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
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(AddressAdapter());

    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(ScripthashUnspentAdapter());
    Hive.registerAdapter(ScripthashHistoryAdapter());
    Hive.registerAdapter(ScripthashBalanceAdapter());
  }

  static Future open() async {
    await Hive.openBox('settings');
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');

    /* replaced by addresses ... */
    await Hive.openBox('scripthashAccountIdInternal');
    await Hive.openBox('scripthashAccountIdExternal');
    await Hive.openBox('scripthashOrderInternal');
    await Hive.openBox('scripthashOrderExternal');
    /* ... */

    await Hive.openBox('balances');
    await Hive.openBox('histories');
    await Hive.openBox('unspents');
    await Hive.openBox('accountUnspents');
  }

  static Future close() async {
    await Hive.close();
  }
}
