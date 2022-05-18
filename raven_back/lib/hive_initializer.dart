import 'dart:io';

import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';
import 'package:ulid/ulid.dart';

/// All: loads all the tables
/// Lock: loads all the tables necessary to display login screen (step 1)
/// Login: loads all the tables necessary to display home screen (the rest) (2)
enum HiveLoadingStep { All, Lock, Login }

class HiveInitializer {
  late final String id;
  late Function init;
  late Function beforeLoad;
  bool destroyOnTeardown;

  String get dbDir => 'database-$id';

  HiveInitializer({
    String? id,
    Function? init,
    Function? beforeLoad,
    this.destroyOnTeardown = false,
  }) {
    this.id = id ?? Ulid().toString();
    this.init = init ?? (dbDir) => Hive.init(dbDir);
    this.beforeLoad = beforeLoad ?? () {};
  }
  Future setUpStart() async {
    registerAdapters();
    await init(dbDir);
  }

  Future setUp(HiveLoadingStep step) async {
    var s = Stopwatch()..start();
    await openBoxes(step);
    print('openAllBoxes: ${s.elapsed}');
    if ([HiveLoadingStep.All, HiveLoadingStep.Lock].contains(step)) {
      beforeLoad();
    }
    print('beforeLoad: ${s.elapsed}');
    load(step);
    print('after load: ${s.elapsed}');
  }

  Future tearDown() async {
    await Hive.close();
    if (destroyOnTeardown) {
      await destroy();
    }
  }

  /// fast so we just do them all at once
  void registerAdapters() {
    Hive.registerAdapter(BalanceAdapter());
    Hive.registerAdapter(BlockAdapter());
    Hive.registerAdapter(AssetAdapter());
    Hive.registerAdapter(LeaderWalletAdapter());
    Hive.registerAdapter(SingleWalletAdapter());
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(VinAdapter());
    Hive.registerAdapter(VoutAdapter());
    Hive.registerAdapter(NetAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(PasswordAdapter());
    Hive.registerAdapter(RateAdapter());
    Hive.registerAdapter(CipherUpdateAdapter());
    Hive.registerAdapter(CipherTypeAdapter());
    Hive.registerAdapter(MetadataTypeAdapter());
    Hive.registerAdapter(MetadataAdapter());
    Hive.registerAdapter(SettingAdapter());
    Hive.registerAdapter(SettingNameAdapter());
    Hive.registerAdapter(StatusAdapter());
    Hive.registerAdapter(StatusTypeAdapter());
    Hive.registerAdapter(SecurityAdapter());
    Hive.registerAdapter(SecurityTypeAdapter());
    Hive.registerAdapter(UnspentAdapter());
  }

  /// address must open before wallets because added in wallets waiter
  /// we look up addresses to get highest hdindex
  Future openBoxes(HiveLoadingStep step) async {
    if ([HiveLoadingStep.All, HiveLoadingStep.Lock].contains(step)) {
      await Hive.openBox<Rate>('rates');
      await Hive.openBox<Password>('passwords');
      await Hive.openBox<Setting>('settings');
      await Hive.openBox<Wallet>('wallets');
    }
    if ([HiveLoadingStep.All, HiveLoadingStep.Login].contains(step)) {
      await Hive.openBox<Address>('addresses');
      await Hive.openBox<Asset>('assets');
      await Hive.openBox<Balance>('balances');
      await Hive.openBox<Block>('blocks');
      await Hive.openBox<Metadata>('metadatas');
      await Hive.openBox<Note>('notes');
      await Hive.openBox<Security>('securities');
      await Hive.openBox<Status>('statuses');
      await Hive.openBox<Transaction>('transactions');
      await Hive.openBox<Vin>('vins');
      await Hive.openBox<Vout>('vouts');
    }
  }

  void load(HiveLoadingStep step) {
    if ([HiveLoadingStep.All, HiveLoadingStep.Lock].contains(step)) {
      /// this needs to be inmemory:
      // res.ciphers.setSource(HiveSource(
      //   'ciphers',
      //   defaults: CipherReservoir.defaults,
      // ));
      res.ciphers.setSource(MapSource(CipherReservoir.defaults));
      res.unspents.setSource(MapSource(UnspentReservoir.defaults));
      res.rates.setSource(HiveSource('rates'));
      res.passwords.setSource(HiveSource('passwords'));
      res.settings.setSource(HiveSource(
        'settings',
        defaults: SettingReservoir.defaults,
      ));
      res.wallets.setSource(HiveSource('wallets'));
    }
    if ([HiveLoadingStep.All, HiveLoadingStep.Login].contains(step)) {
      res.addresses.setSource(HiveSource('addresses'));
      res.balances.setSource(HiveSource('balances'));
      res.blocks.setSource(HiveSource('blocks'));
      res.assets.setSource(HiveSource('assets'));
      res.metadatas.setSource(HiveSource('metadatas'));
      res.notes.setSource(HiveSource('notes'));
      res.securities.setSource(HiveSource(
        'securities',
        defaults: SecurityReservoir.defaults,
      ));
      res.transactions.setSource(HiveSource('transactions'));
      res.vins.setSource(HiveSource('vins'));
      res.vouts.setSource(HiveSource('vouts'));
      res.statuses.setSource(HiveSource('statuses'));
    }
  }

  Future destroy() async {
    var dir = Directory(dbDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
