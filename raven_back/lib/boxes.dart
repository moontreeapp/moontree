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

  Iterable<MapEntry> filterByValueString(String value) {
    var all = getAll();
    return all.where((element) => element.value == value);
  }

  int countByValueString(String value) {
    return filterByValueString(value).length;
  }
}

/// database wrapper singleton
class Truth {
  late Box settings; //     'Electrum Server': 'testnet.rvn.rocks'
  // option 1: include max internal/external to accounts - keep cache
  late Box<AccountStored> accounts; // list
  // option 2: lose cache
  //late Box<List<String>> accountInternals;
  //late Box<List<String>> accountExternals;

  // option 3: every account has it's own box - more complicated than it needs to be
  //late Map<String, Box> accountBoxes = {};

  // option 4: two of these: and run a filter to get index...
  late Box<String> scripthashAccountIdInternal;
  late Box<String> scripthashAccountIdExternal;
  late Box<ScripthashBalance> balances;
  late Box<ScripthashHistory> histories;
  late Box<List<ScripthashUnspent>> unspents;
  late Box<SortedList<ScripthashUnspent>> accountUnspents;

  // make truth a singleton
  static final Truth _singleton = Truth._();

  // singleton accessor
  static Truth get instance => _singleton;

  Truth._() {
    init();
  }

  void init() {
    Hive.init('database');
    Hive.registerAdapter(CachedNodeAdapter());
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
  }

  /// get data from long term storage boxes
  Future<Box> open([String boxName = '']) async {
    if (boxName == '') {
      for (var name in boxes().keys) {
        boxes()[name] = await Hive.openBox(name);
      }
      if (settings.isEmpty) {
        await settings.put('Electrum Server', 'testnet.rvn.rocks');
      }
      return settings;
    } else {
      return await Hive.openBox(boxName);
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
    await accountUnspents.deleteAll(internals);
    await balances.deleteAll(externals);
    await histories.deleteAll(externals);
    await unspents.deleteAll(externals);
    await accountUnspents.deleteAll(externals);
  }

  Future saveAccount(Account account) async {
    await accounts.put(account.accountId,
        {'params': account.params, 'seed': account.seed, 'name': account.name});
  }

  Future getAccounts() async {
    var savedAccounts = [];
    var account;
    for (var i = 0; i < accounts.length; i++) {
      account = await accounts.getAt(i);
      savedAccounts.add(Account(account['params'],
          seed: account['seed'], name: account['name']));
    }
    return savedAccounts;
  }

  /// saves the balance for each node in the account
  Future saveAccountBalance(Account account) async {
    for (var exposure in ['External', 'Internal']) {
      var x = 0;
      for (var node in account.cache) {
        if (node.node.exposure.toString() == exposure) {
          await balances.put(
              account.accountId + exposure + (x).toString(), node.balance);
          x = x + 1;
        }
      }
    }
  }

  /// gets the balance for each node in the account and returns sum
  Future<int> getAccountBalance(Account account) async {
    var nodeBalances = [];
    for (var exposure in ['External', 'Internal']) {
      var x = 0;
      var gap = 0;
      while (gap < 11) {
        nodeBalances.add(await balances.get(
            account.accountId + exposure + (x).toString(),
            defaultValue: 0));
        if (nodeBalances[x] > 0) gap = gap + 1;
        x = x + 1;
      }
    }
    var balance = nodeBalances.reduce((a, b) => a.value + b.value);
    return balance;
  }
}
