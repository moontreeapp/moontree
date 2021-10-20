import 'dart:io';

import 'package:hive/hive.dart';
import 'package:raven/reservoirs/security.dart';
import 'package:raven/reservoirs/setting.dart';
import 'package:reservoir/reservoir.dart';
import 'package:ulid/ulid.dart';

import 'records/records.dart';
import 'globals.dart';

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
    setSources();
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
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(VinAdapter());
    Hive.registerAdapter(VoutAdapter());
    Hive.registerAdapter(NetAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(PasswordAdapter());
    Hive.registerAdapter(RateAdapter());
    Hive.registerAdapter(CipherUpdateAdapter());
    Hive.registerAdapter(CipherTypeAdapter());
    Hive.registerAdapter(SettingAdapter());
    Hive.registerAdapter(SettingNameAdapter());
    Hive.registerAdapter(SecurityAdapter());
    Hive.registerAdapter(SecurityTypeAdapter());
  }

  Future openAllBoxes() async {
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');
    await Hive.openBox<Balance>('balances');
    await Hive.openBox<Block>('blocks');
    await Hive.openBox<Password>('passwords');
    await Hive.openBox<Rate>('rates');
    await Hive.openBox<Security>('securities');
    await Hive.openBox<Setting>('settings');
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<Wallet>('wallets');
    await Hive.openBox<Vin>('vins');
    await Hive.openBox<Vout>('vouts');
  }

  void setSources() {
    accounts.setSource(HiveSource('accounts'));
    addresses.setSource(HiveSource('addresses'));
    balances.setSource(HiveSource('balances'));
    blocks.setSource(HiveSource('blocks'));

    /// this needs to be inmemory:
    // ciphers.setSource(HiveSource(
    //   'ciphers',
    //   defaults: CipherReservoir.defaults,
    // ));

    passwords.setSource(HiveSource('passwords'));
    rates.setSource(HiveSource('rates'));
    securities.setSource(HiveSource(
      'securities',
      defaults: SecurityReservoir.defaults,
    ));
    settings.setSource(HiveSource(
      'settings',
      defaults: SettingReservoir.defaults,
    ));
    transactions.setSource(HiveSource('transactions'));
    wallets.setSource(HiveSource('wallets'));
    vins.setSource(HiveSource('vins'));
    vouts.setSource(HiveSource('vouts'));
  }

  Future destroy() async {
    var dir = Directory(dbDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
