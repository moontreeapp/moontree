// ignore_for_file: avoid_print, avoid_slow_async_io, omit_local_variable_types

import 'dart:io';

import 'package:ulid/ulid.dart';
import 'package:hive/hive.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/consent/consent_client.dart';

/// All: loads all the tables
/// Lock: loads all the tables necessary to display login screen (step 1)
/// Login: loads all the tables necessary to display home screen (the rest) (2)
enum HiveLoadingStep { all, lock, login }

class HiveInitializer {
  late final String id;
  late Function init;
  late VoidCallback beforeLoad;
  bool destroyOnTeardown;

  String get dbDir => 'database-$id';

  HiveInitializer({
    String? id,
    Function? init,
    VoidCallback? beforeLoad,
    this.destroyOnTeardown = false,
  }) {
    this.id = id ?? Ulid().toString();
    this.init = init ?? (String? dbDir) => Hive.init(dbDir);
    this.beforeLoad = beforeLoad ?? () {};
  }
  Future<void> setUpStart() async {
    registerAdapters();
    await init(dbDir);
  }

  Future<void> setUp(HiveLoadingStep step) async {
    await openBoxes(step);
    if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.lock]
        .contains(step)) {
      beforeLoad();
    }
    load(step);
  }

  Future<void> tearDown() async {
    await Hive.close();
    if (destroyOnTeardown) {
      await destroy();
    }
  }

  /// fast so we just do them all at once
  void registerAdapters() {
    print('REGISTRING!');
    Hive.registerAdapter(AuthMethodAdapter());
    Hive.registerAdapter(BalanceAdapter());
    Hive.registerAdapter(BlockAdapter());
    Hive.registerAdapter(ChainAdapter());
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
    Hive.registerAdapter(FeatureLevelAdapter());
    Hive.registerAdapter(TutorialStatusAdapter());
    Hive.registerAdapter(CachedServerObjectAdapter());
  }

  /// address must open before wallets because added in wallets waiter
  /// we look up addresses to get highest hdindex
  Future<void> openBoxes(HiveLoadingStep step) async {
    if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.lock]
        .contains(step)) {
      await Hive.openBox<Rate>('rates');
      await Hive.openBox<Password>('passwords');
      await Hive.openBox<Setting>('settings');
      await Hive.openBox<Wallet>('wallets');
      // should be here? not if it gets big.
      await Hive.openBox<CachedServerObject>('cache');
    }
    if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.login]
        .contains(step)) {
      await Hive.openBox<Address>('addresses');
      await Hive.openBox<Balance>('balances');
      await Hive.openBox<Block>('blocks');
      await Hive.openBox<Note>('notes');
      await Hive.openBox<Security>('securities');

      /// unused in v2
      //await Hive.openBox<Status>('statuses');
      //await Hive.openBox<Asset>('assets');
      //await Hive.openBox<Metadata>('metadatas');
      //await Hive.openBox<Transaction>('transactions');
      //await Hive.openBox<Unspent>('unspents');
      //await Hive.openBox<Vin>('vins');
      //await Hive.openBox<Vout>('vouts');
    }
  }

  void load(HiveLoadingStep step) {
    if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.lock]
        .contains(step)) {
      //pros.secrets.setSource(MapSource(SecretProclaim.defaults));
      /// this needs to be inmemory:
      pros.ciphers.setSource(MapSource<Cipher>(CipherProclaim.defaults));
      pros.rates.setSource(HiveSource<Rate>('rates'));
      pros.passwords.setSource(HiveSource<Password>('passwords'));
      pros.settings.setSource(HiveSource<Setting>(
        'settings',
        defaults: SettingProclaim.defaults,
      ));
      pros.wallets.setSource(HiveSource<Wallet>('wallets'));
      pros.cache.setSource(HiveSource<CachedServerObject>('cache'));
    }
    if (<HiveLoadingStep>[HiveLoadingStep.all, HiveLoadingStep.login]
        .contains(step)) {
      //pros.unspents.setSource(HiveSource<Unspent>('unspents'));
      pros.addresses.setSource(HiveSource<Address>('addresses'));
      pros.balances.setSource(HiveSource<Balance>('balances'));
      pros.blocks.setSource(HiveSource<Block>('blocks'));
      pros.notes.setSource(HiveSource<Note>('notes'));
      pros.securities.setSource(HiveSource<Security>(
        'securities',
        defaults: SecurityProclaim.defaults,
      ));

      /// unused in v2
      //pros.statuses.setSource(HiveSource<Status>('statuses'));
      //pros.assets.setSource(HiveSource<Asset>('assets'));
      //pros.metadatas.setSource(HiveSource<Metadata>('metadatas'));
      //pros.transactions.setSource(HiveSource<Transaction>('transactions'));
      //pros.vins.setSource(HiveSource<Vin>('vins'));
      //pros.vouts.setSource(HiveSource<Vout>('vouts'));

    }
  }

  Future<void> destroy() async {
    final Directory dir = Directory(dbDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
