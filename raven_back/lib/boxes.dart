import 'dart:async';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:raven_electrum_client/methods/get_balance.dart';
import 'account.dart';
import 'box_adapters.dart';

/// database wrapper singleton
class Truth {
  late Box settings; // 'Electrum Server': 'testnet.rvn.rocks'
  late Box accounts; // uid: {params: params, seed: seed, name: name}
  late Box
      nodes; //         uid: [{exposure: exposure, index: index, scripthash: scripthash}]
  late Box hashes; //   scripthash: uid
  late Box balances; // scripthash: ScriptHashBalance balance
  late Box unspents; // scripthash: List utxos
  late Box utxos; //    scripthash: List sorted list of utxos

  // make truth a singleton
  static final Truth _singleton = Truth._internal();

  // singleton accessor
  static Truth get instance => _singleton;

  Truth._internal() {
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
    Hive.registerAdapter(ScriptHashUnspentAdapter());
    Hive.registerAdapter(ScriptHashHistoryAdapter());
    Hive.registerAdapter(ScriptHashBalanceAdapter());
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

  /// returns all our boxes
  Map<String, Box> boxes() {
    return {
      'settings': settings,
      'accounts': accounts,
      'hashes': hashes,
      'nodes': nodes,
      'balances': balances,
      'unspents': unspents,
      'utxos': utxos,
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

  Future saveAccount(Account account) async {
    accounts = await open('accounts');
    await accounts.put(account.uid,
        {'params': account.params, 'seed': account.seed, 'name': account.name});
    await accounts.close();
  }

  Future getAccounts() async {
    accounts = await open('accounts');
    var savedAccounts = [];
    var account;
    for (var i = 0; i < accounts.length; i++) {
      account = await accounts.getAt(i);
      savedAccounts.add(Account(account['params'],
          seed: account['seed'], name: account['name']));
    }
    await accounts.close();
    return savedAccounts;
  }

  /// saves the balance for each node in the account
  Future saveAccountBalance(Account account) async {
    balances = await open('balances');
    for (var exposure in ['External', 'Internal']) {
      var x = 0;
      for (var node in account.cache) {
        if (node.node.exposure.toString() == exposure) {
          await balances.put(
              account.uid + exposure + (x).toString(), node.balance);
          x = x + 1;
        }
      }
    }
    await balances.close();
  }

  /// gets the balance for each node in the account and returns sum
  Future<int> getAccountBalance(Account account) async {
    balances = await open('balances');
    var nodeBalances = [];
    for (var exposure in ['External', 'Internal']) {
      var x = 0;
      var gap = 0;
      while (gap < 11) {
        nodeBalances.add(await balances
            .get(account.uid + exposure + (x).toString(), defaultValue: 0));
        if (nodeBalances[x] > 0) gap = gap + 1;
        x = x + 1;
      }
    }
    var balance = nodeBalances.reduce((a, b) => a.value + b.value);
    await balances.close();
    return balance;
  }
}
