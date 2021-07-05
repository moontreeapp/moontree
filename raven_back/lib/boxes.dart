import 'dart:async';
import 'package:hive/hive.dart';
import 'account.dart';
import 'box_adapters.dart';

/// database wrapper singleton
class Truth {
  bool uninitialized = true;
  late Box settings;
  late Box accounts;
  late Box balances;
  //Map<String, Box> boxes = {};

  // make truth a singleton
  static final Truth _singleton = Truth._internal();

  // singleton accessor
  static Truth get instance => _singleton;

  //factory Truth() {
  //  init();
  //  return _singleton;
  //}

  Truth._internal();

  void init() {
    //final appDocumentDir = await getApplicationDocumentDirectory();
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
    uninitialized = false;
  }

  /// get data from long term storage boxes
  Future open([String boxName = '']) async {
    if (uninitialized) init();
    if (boxName == '') {
      settings = await Hive.openBox('settings');
      accounts = await Hive.openBox('accounts');
      balances = await Hive.openBox('balances');
      //nodes = await Hive.openBox<CachedNode>('nodes');
      if (settings.isEmpty) {
        await settings.put('Electrum Server', 'testnet.rvn.rocks');
      }
    } else {
      return await Hive.openBox(boxName);
    }
  }

  Future close() async {
    for (var box in [settings, accounts, balances]) {
      await box.close();
    }
  }

  Future clear() async {
    for (var box in [settings, accounts, balances]) {
      await box.clear();
    }
  }

  Future saveAccount(Account account) async {
    accounts = await open('accounts');
    await accounts.put(account.uid,
        {'params': account.params, 'seed': account.seed, 'name': account.name});
    await accounts.close();
  }

  Future saveAccountBalance(Account account) async {
    balances = await open('balances');
    await balances.put(account.uid, account.getBalance());
    await balances.close();
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

  Future getAccountBalance(Account account) async {
    balances = await open('balances');
    var balance = balances.get(account.uid, defaultValue: 0);
    await balances.close();
    return balance;
  }
}


/*
Schema: `box = {key: value}`

settings = {
  'Electrum Server': 'testnet.rvn.rocks'
}
accounts = {
  unique id (seed hash): {params: params, seed: seed, name: name}  // just metadata
}
balances = {
  unique id (seed hash): balance (int)
}


/// this one caused too many problems since it was full of nested structure
nodes = {
  composite key (account seed hash + exposure + nodeIndex): cachedNode (node, Map balance, List histories, List utxos)
}

electrum subscriptions replace cachedNode objects at the composite key upon events 
user changes to "wallet" or account name/params replace account at uinque id (hash of seed?) without changing nodes

replace cachedNode objects at the composite key upon events 


*/
