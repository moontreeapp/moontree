import 'package:hive/hive.dart';
import 'package:raven/records.dart';

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
    Hive.registerAdapter(BalanceAdapter());
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(LeaderWalletAdapter());
    Hive.registerAdapter(SingleWalletAdapter());
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(NetAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(RateAdapter());
    Hive.registerAdapter(SettingAdapter());
    Hive.registerAdapter(SettingNameAdapter());
    Hive.registerAdapter(SecurityAdapter());
    Hive.registerAdapter(SecurityTypeAdapter());
  }

  static Future open() async {
    await Hive.openBox<Setting>('settings');
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');
    await Hive.openBox<LeaderWallet>('leaders');
    await Hive.openBox<SingleWallet>('singles');
    await Hive.openBox<History>('histories');
    await Hive.openBox<Rate>('rates');
    await Hive.openBox<Balance>('balances');
  }

  static Future close() async {
    await Hive.close();
  }
}
