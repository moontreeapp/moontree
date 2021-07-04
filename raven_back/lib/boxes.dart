import 'dart:async';
import 'package:hive/hive.dart';
import 'account.dart';
import 'box_adapters.dart';

/// database wrapper singleton
class Truth {
  bool uninitialized = true;
  Map<String, Box> boxes = {};

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

  Future clear([String boxName = '']) async {
    for (var name in boxes.keys) {
      if (boxName == '' || boxName == name) {
        await boxes[name]!.clear();
      }
    }
  }

  Future close([String boxName = '']) async {
    for (var name in boxes.keys) {
      if (boxName == '' || boxName == name) {
        await boxes[name]!.close();
      }
    }
  }

  /// get data from long term storage boxes
  Future load() async {
    boxes['settings'] = await Hive.openBox('settings');
    boxes['accounts'] = await Hive.openBox('accounts');
    boxes['balances'] = await Hive.openBox('balances');
    //boxes['nodes'] = await Hive.openBox<CachedNode>('nodes');
    if (boxes['settings']!.isEmpty) {
      await boxes['settings']!.put('Electrum Server', 'testnet.rvn.rocks');
    }
  }

  Future saveAccount(Account account) async {
    if (uninitialized) init();
    await load();
    await boxes['accounts']!.put(account.uid,
        {'params': account.params, 'seed': account.seed, 'name': account.name});
    await close();
  }

  Future saveAccountBalance(Account account) async {
    if (uninitialized) init();
    await load();
    await boxes['balances']!.put(account.uid, account.getBalance());
    await close();
  }

  Future getAccounts() async {
    if (uninitialized) init();
    await load();
    var accounts = [];
    var account;
    for (var i = 0; i < boxes['accounts']!.length; i++) {
      account = await boxes['accounts']!.getAt(i);
      accounts.add(Account(account['params'],
          seed: account['seed'], name: account['name']));
    }
    await close();
    return accounts;
  }

  Future getAccountBalance(Account account) async {
    if (uninitialized) init();
    await load();
    var balance = boxes['balances']!.get(account.uid, defaultValue: 0);
    await close();
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
