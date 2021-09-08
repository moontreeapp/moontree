import 'change.dart';
import 'source.dart';

class MapSource<Record> extends Source<Record> {
  late final Map<String, Record> map;

  MapSource([Map<String, Record>? map]) : map = map ?? {};

  @override
  Iterable<Record> initialLoad() {
    return map.values;
  }

  @override
  Future<Change?> save(String key, Record record) async {
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
  Future<Change?> remove(String key) async {
    var existing = map[key];
    if (existing == null) {
      return null;
    } else {
      map.remove(key);
      return Removed(key, existing);
    }
  }
}
