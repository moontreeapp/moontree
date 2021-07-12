import 'dart:async';
import 'package:quiver/iterables.dart';
import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:sorted_list/sorted_list.dart';
import 'account.dart';
import 'box_adapters.dart';

extension GetAll on Box {
  Iterable<MapEntry> getAll() {
    return zip([keys, values]).map((e) => MapEntry(e[0], e[1]));
  }
}

extension FilterByValue on Box {
  Iterable<MapEntry> filterByValueString(String value) {
    return getAll().where((element) => element.value == value);
  }

  Iterable filterKeysByValueString(String value) {
    return Map.fromEntries(getAll().where((element) => element.value == value))
        .keys;
  }
}

extension FilterByKeys on Box {
  Iterable filterByKeys(List keys) {
    return getAll().where((element) => keys.contains(element.key));
  }

  Iterable filterValuesByKeys(List keys) {
    return Map.fromEntries(
        getAll().where((element) => keys.contains(element.key))).values;
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
  bool isOpen = false;
  late Box settings; // 'Electrum Server': 'testnet.rvn.rocks'
  late Box<AccountStored> accounts; // list
  late Box<String> scripthashAccountIdInternal; // scripthash: accountId
  late Box<String> scripthashAccountIdExternal; // scripthash: accountId
  late Box<ScripthashBalance> balances; // scripthash: obj
  late Box<List<ScripthashHistory>> histories; // scripthash: obj
  late Box<List<ScripthashUnspent>> unspents; // scripthash: obj
  late Box<SortedList<ScripthashUnspent>> accountUnspents; // accountId: list

  // make truth a singleton
  static final Truth _singleton = Truth._();

  // singleton accessor
  static Truth get instance => _singleton;

  Truth._() {
    init();
  }

  void init() {
    Hive.init('database');
    Hive.registerAdapter(HDNodeAdapter());
    Hive.registerAdapter(NetworkParamsAdapter());
    Hive.registerAdapter(NetworkTypeAdapter());
    Hive.registerAdapter(Bip32TypeAdapter());
    Hive.registerAdapter(HDWalletAdapter());
    Hive.registerAdapter(P2PKHAdapter());
    Hive.registerAdapter(PaymentDataAdapter());
    Hive.registerAdapter(NodeExposureAdapter());
    Hive.registerAdapter(ScripthashUnspentAdapter());
    Hive.registerAdapter(ScripthashHistoryAdapter());
    Hive.registerAdapter(ScripthashBalanceAdapter());
    Hive.registerAdapter(AccountStoredAdapter());
  }

  /// get data from long term storage boxes
  Future open() async {
    if (isOpen) {
      return;
    }
    settings = await Hive.openBox('settings');
    accounts = await Hive.openBox('accounts');
    scripthashAccountIdInternal =
        await Hive.openBox('scripthashAccountIdInternal');
    scripthashAccountIdExternal =
        await Hive.openBox('scripthashAccountIdExternal');
    balances = await Hive.openBox('balances');
    histories = await Hive.openBox('histories');
    unspents = await Hive.openBox('unspents');
    accountUnspents = await Hive.openBox('accountUnspents');
    //for (var name in boxes().keys) {
    //  boxes()[name] = await Hive.openBox(name);
    //}
    await loadDefaults();
    isOpen = true;
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
    await balances.deleteAll(internals);
    await histories.deleteAll(internals);
    await unspents.deleteAll(internals);
    await balances.deleteAll(externals);
    await histories.deleteAll(externals);
    await unspents.deleteAll(externals);
  }

  Future saveAccount(Account account) async {
    await accounts.add(AccountStored(account.symmetricallyEncryptedSeed,
        networkParams: account.params, name: account.name));
  }

  Future getAccounts() async {
    var savedAccounts = [];
    for (var i = 0; i < accounts.length; i++) {
      var accountStored = accounts.getAt(i);
      savedAccounts.add(Account.fromAccountStored(accountStored!));
    }
    return savedAccounts;
  }

  /// gets the balance for each node in the account and returns sum
  int getAccountBalance(Account account) {
    //print(account.accountScripthashes);
    //for (var sh in account.accountScripthashes) {
    //  print('sh');
    //  print(sh);
    //  print(balances.get(sh));
    //}
    print(account.accountScripthashes);
    print(balances.keys);
    print(balances.filterByKeys(account.accountScripthashes));
    print(balances.filterByKeys(account.accountScripthashes).runtimeType);
    //Map<String, dynamic>.from(snapshot.value)
    //(scripthashes.map((item) => Map(item[0], )).toList()
    return 1;

    //return balances
    //    .filterByKeys(account.accountScripthashes)
    //    .reduce((a, b) => a.value + b.value); //  type '(dynamic, dynamic) => dynamic' is not a subtype of type '(MapEntry<dynamic, dynamic>, MapEntry<dynamic, dynamic>) => MapEntry<dynamic, dynamic>' of 'combine'
    //.reduce((ScripthashBalance a, ScripthashBalance b) => a.value + b.value);
  }
}
