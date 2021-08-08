import 'package:hive/hive.dart';
import '../records.dart';

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
    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(BalancesAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(NetAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(RateAdapter());
  }

  static Future open() async {
    await Hive.openBox('settings');
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');
    await Hive.openBox<Wallet>('wallets');
    await Hive.openBox<History>('histories');
    await Hive.openBox<Rate>('rates');

    /// do we have a box of balances?
    /// if so should we just index balances?
    /// balances are saved on the addresses
    //await Hive.openBox<Balance>('balances');
  }

  static Future close() async {
    await Hive.close();
  }
}
