import 'package:reservoir/change.dart';
import 'package:reservoir/source.dart';

class MapSource<Key extends Object, Record extends Object>
    extends Source<Key, Record> {
  final Map map = {};

  @override
  Iterable<Record> initialLoad() {
    // Do nothing, since RxMap always starts without values
    return [];
  }

  @override
  Future<Change?> save(Key key, Record record) async {
    var existing = map[key];
    if (existing == record) {
      return null;
    } else if (existing == null) {
      map[key] = record;
      return Added(key, record);
    } else {
      map[key] = record;
      return Updated(key, record);
    }
  }

  @override
  Future<Change?> remove(Key key) async {
    var existing = map[key];
    if (existing == null) {
      return null;
    } else {
      map.remove(key);
      return Removed(key, existing);
    }
  }
}
