import 'dart:io';

import 'package:hive/hive.dart';
import 'package:raven/records/records.dart';
import 'package:ulid/ulid.dart';

class HiveInitializer {
  late final String id;
  late Function init;
  bool destroyOnTeardown;

  String get dbDir => 'database-$id';

  HiveInitializer(
      {String? id, Function? init, this.destroyOnTeardown = false}) {
    this.id = id ?? Ulid().toString();
    this.init = init ?? (dbDir) => Hive.init(dbDir);
  }

  Future setUp() async {
    registerAdapters();
    await init(dbDir);
    await openAllBoxes();
  }

  Future tearDown() async {
    await Hive.close();
    if (destroyOnTeardown) {
      await destroy();
    }
  }

  void registerAdapters() {
    Hive.registerAdapter(BalanceAdapter());
    Hive.registerAdapter(BlockAdapter());
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

  Future openAllBoxes() async {
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');
    await Hive.openBox<Balance>('balances');
    await Hive.openBox<Balance>('blocks');
    await Hive.openBox<History>('histories');
    await Hive.openBox<Rate>('rates');
    await Hive.openBox<Setting>('settings');
    await Hive.openBox<Wallet>('wallets');
  }

  Future destroy() async {
    var dir = Directory(dbDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}