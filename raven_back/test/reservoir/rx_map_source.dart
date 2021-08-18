import 'package:equatable/equatable.dart';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoir/source.dart';

class MapSource<Key, Record extends Equatable> extends Source<Key, Record> {
  final Map map = {};

  @override
  void initialLoad(AddRecord<Record> addRecord) {
    // Do nothing, since RxMap always starts without values
  }

  @override
  Future<Change?> save(Key key, Record record) async {
    var existing = map[key];
    if (existing == null) {
      map[key] = record;
      return Added(key, record);
    } else if (existing == record) {
      return null;
    } else {
      map[key] = record;
      return Updated(key, record);
    }
  }

  @override
  Future<Change?> remove(Key key) async {
    if (map.containsKey(key)) {
      map.remove(key);
      return Removed(key);
    }
  }
}
