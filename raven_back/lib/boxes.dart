import 'dart:async';

import 'package:hive/hive.dart';

import 'box_adapters.dart';

import 'dart:async';
//import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:sembast/sembast.dart';
//import 'package:sembast/sembast_io.dart';

//class AppDatabase {
//  // singleton instance
//  static final AppDatabase _singleton = AppDatabase._();
//  // singleton accessor
//  static AppDatabase get instance => _singleton;
//  // turns async code into sync code
//  Completer<Database> _dbOpenCompleter;
//  AppDatabase._();
//
//  Future<Database> get database async {
//    if (_dbOpenCompleter == null) {
//      _dbOpenCompleter = Completer();
//      _openDatabase();
//    }
//  }
//
//  Future _openDatabase() async {
//    //final appDocumentDir = await getApplicationDocumentDirectory();
//    final appDocumentDir = await getApplicationDocumentDirectory();
//    final dbPath = join(appDocumentDir.path, 'demo.db');
//    final database = await databaseFactoryIo.openDatabase(dbPath);
//    _dbOpenCompleter.complete(database);
//  }
//}

/// Truth should be instantiated only once... is there a different solution for this situation?
/// FileSystemException: lock failed, path = 'database\settings.lock'
/// (OS Error: The process cannot access the file because another process has locked a portion of the file., errno = 33)
/// therefore you have to close it before anything else opens it. so having one long-running instanteation is best.

class Truth {
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

  Future init() async {
    //final appDocumentDir = await getApplicationDocumentDirectory();
    Hive.init('database');
    //Hive.registerAdapter(CachedNodeAdapter());
    //Hive.registerAdapter(HDNodeAdapter());
    Hive.registerAdapter(NetworkParamsAdapter());
    Hive.registerAdapter(NetworkTypeAdapter());
    Hive.registerAdapter(Bip32TypeAdapter());
    ////Hive.registerAdapter(HDWalletAdapter());
    ////Hive.registerAdapter(BIP32Adapter());
    //Hive.registerAdapter(P2PKHAdapter());
    //Hive.registerAdapter(PaymentDataAdapter());
    await load();
  }

  Future clear([String boxName = '']) async {
    for (var name in boxes.keys) {
      if (boxName == '' || boxName == name) {
        print(name);
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
    // can we move this into constructor? I don't think we can because of await
    boxes['settings'] = await Hive.openBox('settings');
    boxes['accounts'] = await Hive.openBox('accounts');
    boxes['nodes'] = await Hive.openBox('nodes');
    //boxes['nodes'] = await Hive.openBox<CachedNode>('nodes');

    if (boxes['settings']!.isEmpty) {
      // first time running the app - initialize it with settings
      await boxes['settings']!.put('Electrum Server', 'testnet.rvn.rocks');
    }
    // print('length: ${boxes['settings']!.length}');
    // print('Electrum Server: ${boxes['settings']!.get('Electrum Server')}');
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
nodes = {
  composite key (account seed hash + exposure + nodeIndex): cachedNode (node, Map balance, List histories, List utxos)
}

electrum subscriptions replace cachedNode objects at the composite key upon events 
user changes to "wallet" or account name/params replace account at uinque id (hash of seed?) without changing nodes

replace cachedNode objects at the composite key upon events 


*/
