import 'dart:async';
import 'package:quiver/iterables.dart';
import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'account.dart';
import 'cipher.dart';
import 'records.dart' as records;

extension GetAs on Box {
  List<T> getAsList<T>(dynamic key, {dynamic defaultValue}) {
    return List<T>.from(get(key, defaultValue: defaultValue) ?? []);
  }

  List<T> getAtAsList<T>(int index) {
    return List<T>.from(getAt(index) ?? []);
  }
}

extension GetAll on Box {
  /// they are not in temporal order, but are they in the same order?
  Iterable<MapEntry> getAll() {
    return zip([keys, values]).map((e) => MapEntry(e[0], e[1]));
  }
}

extension FilterByValue on Box {
  Iterable<MapEntry> filterByValueString(String value) {
    return getAll().where((element) => element.value == value);
  }

  /// I think this unorders it...
  Iterable filterKeysByValueString(String value) {
    return Map.fromEntries(filterByValueString(value)).keys;
  }
}

extension FilterByKeys on Box {
  Iterable<MapEntry<dynamic, dynamic>> filterByKeys(List keys) {
    return getAll().where((element) => keys.contains(element.key));
  }

  Map<dynamic, dynamic> filterAllByKeys(List keys) {
    return Map.fromEntries(filterByKeys(keys));
  }

  Iterable filterValuesByKeys(List keys) {
    return filterAllByKeys(keys).values;
  }
}

extension CountByValue on Box {
  int countByValueString(String value) {
    return filterByValueString(value).length;
  }
}

extension GetOf on Box {
  Iterable<dynamic> elementOf(String accountId) {
    return values.where((element) => element.accountId == accountId);
  }

  int indexOf(String accountId) {
    var i = 0;
    for (var value in values) {
      if (value.accountId == accountId) {
        return i;
      }
      i = i + 1;
    }
    return -1;
  }
}

/// database wrapper singleton
class Truth {
  bool isInitialized = false;
  bool isOpen = false;
  late Box settings; // 'Electrum Server': 'testnet.rvn.rocks'
  late Box<records.Account> accounts; // list
  late Box<String> scripthashAccountIdInternal; // scripthash: accountId
  late Box<String> scripthashAccountIdExternal; // scripthash: accountId
  late Box<int> scripthashOrderInternal; // scripthash: int
  late Box<int> scripthashOrderExternal; // scripthash: int
  late Box<ScripthashBalance> balances; // scripthash: obj
  late Box<List<dynamic>> histories; // scripthash: list
  late Box<List<dynamic>> unspents; // scripthash: list
  late Box<List<dynamic>> accountUnspents; // accountId: list

  // make truth a singleton
  static final Truth _singleton = Truth._();

  // singleton accessor
  static Truth get instance => _singleton;

  Truth._();

  void init() {
    //Hive.init('database'); initialized with flutter in raven_mobile...
    Hive.registerAdapter(records.AccountAdapter());
    Hive.registerAdapter(records.HDNodeAdapter());
    Hive.registerAdapter(records.NodeExposureAdapter());
    Hive.registerAdapter(records.ScripthashUnspentAdapter());
    Hive.registerAdapter(records.ScripthashHistoryAdapter());
    Hive.registerAdapter(records.ScripthashBalanceAdapter());
    isInitialized = true;
  }

  /// get data from long term storage boxes
  Future open() async {
    if (!isInitialized) {
      // not being used in flutter project - init Hive (for testing purposes)
      Hive.init('database');
      init();
    }
    if (isOpen) {
      ///... Hive.isBoxOpen
      return;
    }
    settings = await Hive.openBox('settings');
    accounts = await Hive.openBox('accounts');
    scripthashAccountIdInternal =
        await Hive.openBox('scripthashAccountIdInternal');
    scripthashAccountIdExternal =
        await Hive.openBox('scripthashAccountIdExternal');
    scripthashOrderInternal = await Hive.openBox('scripthashOrderInternal');
    scripthashOrderExternal = await Hive.openBox('scripthashOrderExternal');
    balances = await Hive.openBox('balances');
    histories = await Hive.openBox('histories');
    unspents = await Hive.openBox('unspents');
    accountUnspents = await Hive.openBox('accountUnspents');

    /*
    when reissuing assets we need: 
      VOUT of previous issue/reissue transaction
      query txid from electrum server - verify that we own the address
    */

    /// we can't sort as we go  because of this error
    /// type 'List<dynamic>' is not a subtype of type 'SortedList<ScripthashUnspent>?' in type cast
    //accountUnspents =
    //    await Hive.openBox<SortedList<ScripthashUnspent>>('accountUnspents');

    //for (var name in boxes().keys) {
    //  boxes()[name] = await Hive.openBox(name);
    //}
    await loadDefaults();
    isOpen = true;
  }

  /// get data from long term storage boxes
  Future<Box> openABox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  Future loadDefaults() async {
    if (settings.isEmpty) {
      await settings.put('Electrum Server', 'testnet.rvn.rocks');
    }
  }

  Map<String, Box> boxes() {
    return {
      'settings': settings,
      'accounts': accounts,
      'scripthashAccountIdInternals': scripthashAccountIdInternal,
      'scripthashAccountIdExternals': scripthashAccountIdExternal,
      'scripthashOrderInternal': scripthashOrderInternal,
      'scripthashOrderExternal': scripthashOrderExternal,
      'balances': balances,
      'histories': histories,
      'unspents': unspents,
      'accountUnspents': accountUnspents,
    };
  }

  Future close() async {
    for (var box in boxes().values) {
      await box.close();
    }
  }

  Future clear() async {
    for (var box in boxes().values) {
      await box.clear();
    }
  }

  Future removeAccountId(String accountId) async {
    await removeScripthashesOf(accountId);
    await accountUnspents.delete(accountId);
    var index = accounts.indexOf(accountId);
    while (index > -1) {
      await accounts.delete(index);
      index = accounts.indexOf(accountId);
    }
  }

  Future removeScripthashesOf(String accountId) async {
    var internals = Map.fromIterable(
            scripthashAccountIdInternal.filterByValueString(accountId))
        .keys;
    var externals = Map.fromIterable(
            scripthashAccountIdExternal.filterByValueString(accountId))
        .keys;
    await scripthashAccountIdInternal.deleteAll(internals);
    await scripthashAccountIdExternal.deleteAll(externals);
    await scripthashOrderInternal.deleteAll(internals);
    await scripthashOrderExternal.deleteAll(externals);
    await balances.deleteAll(internals);
    await histories.deleteAll(internals);
    await unspents.deleteAll(internals);
    await balances.deleteAll(externals);
    await histories.deleteAll(externals);
    await unspents.deleteAll(externals);
  }

  Future saveAccount(Account account) async {
    await accounts.add(records.Account(account.symmetricallyEncryptedSeed,
        networkWif: account.network.wif, name: account.name));
  }

  Future getAccounts() async {
    var savedAccounts = [];
    for (var i = 0; i < accounts.length; i++) {
      var accountStored = accounts.getAt(i);
      savedAccounts.add(Account.fromAccountStored(accountStored!, CIPHER));
    }
    return savedAccounts;
  }

  /// gets the balance for each node in the account and returns sum
  int getAccountBalance(Account account) {
    return balances.filterValuesByKeys(account.accountScripthashes).fold(
        0,
        (previousValue, element) =>
            previousValue + (element as ScripthashBalance).value);
  }
}
