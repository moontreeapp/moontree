import 'package:hive/hive.dart';

/// Truth should be instantiated only once... is there a different solution for this situation?
/// FileSystemException: lock failed, path = 'database\settings.lock'
/// (OS Error: The process cannot access the file because another process has locked a portion of the file., errno = 33)
/// therefore you have to close it before anything else opens it. so having one long-running instanteation is best.
class Truth {
  Map<String, Box> boxes = {};

  Truth() {
    Hive.init('database');
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
