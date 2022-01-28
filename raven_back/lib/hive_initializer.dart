import 'dart:io';

import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';
import 'package:ulid/ulid.dart';

import 'records/records.dart';

class HiveInitializer {
  late final String id;
  late Function init;
  late Function beforeLoad;
  bool destroyOnTeardown;

  String get dbDir => 'database-$id';

  HiveInitializer(
      {String? id,
      Function? init,
      Function? beforeLoad,
      this.destroyOnTeardown = false}) {
    this.id = id ?? Ulid().toString();
    this.init = init ?? (dbDir) => Hive.init(dbDir);
    this.beforeLoad = beforeLoad ?? () {};
  }

  Future setUp() async {
    registerAdapters();
    await init(dbDir);
    await openAllBoxes();
    beforeLoad();
    load();
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
    Hive.registerAdapter(AssetAdapter());
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
    Hive.registerAdapter(MetadataTypeAdapter());
    Hive.registerAdapter(MetadataAdapter());
    Hive.registerAdapter(SettingAdapter());
    Hive.registerAdapter(SettingNameAdapter());
    Hive.registerAdapter(SecurityAdapter());
    Hive.registerAdapter(SecurityTypeAdapter());
  }

  Future openAllBoxes() async {
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Address>('addresses');
    await Hive.openBox<Asset>('assets');
    await Hive.openBox<Balance>('balances');
    await Hive.openBox<Block>('blocks');
    await Hive.openBox<Metadata>('metadatas');
    await Hive.openBox<Password>('passwords');
    await Hive.openBox<Rate>('rates');
    await Hive.openBox<Security>('securities');
    await Hive.openBox<Setting>('settings');
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<Vin>('vins');
    await Hive.openBox<Vout>('vouts');
    await Hive.openBox<Wallet>('wallets');
  }

  void load() {
    res.accounts.setSource(HiveSource('accounts'));
    res.addresses.setSource(HiveSource('addresses'));
    res.balances.setSource(HiveSource('balances'));
    res.blocks.setSource(HiveSource('blocks'));
    res.assets.setSource(HiveSource('assets'));
    res.metadatas.setSource(HiveSource('metadatas'));

    /// this needs to be inmemory:
    // res.ciphers.setSource(HiveSource(
    //   'ciphers',
    //   defaults: CipherReservoir.defaults,
    // ));
    res.ciphers.setSource(MapSource(CipherReservoir.defaults));

    res.passwords.setSource(HiveSource('passwords'));
    res.rates.setSource(HiveSource('rates'));
    res.securities.setSource(HiveSource(
      'securities',
      defaults: SecurityReservoir.defaults,
    ));
    res.settings.setSource(HiveSource(
      'settings',
      defaults: SettingReservoir.defaults,
    ));
    res.transactions.setSource(HiveSource('transactions'));
    res.vins.setSource(HiveSource('vins'));
    res.vouts.setSource(HiveSource('vouts'));
    res.wallets.setSource(HiveSource('wallets'));
  }

  Future destroy() async {
    var dir = Directory(dbDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
