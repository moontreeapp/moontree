import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'change.dart';
import 'source.dart';

class HiveSource<Key extends Object, Record extends Object>
    extends Source<Key, Record> {
  final String name;
  late final Box<Record> box;

  HiveSource(this.name);

  // Return initial Hive box records to be used to populate Reservoir
  @override
  Iterable<Record> initialLoad() {
    return Hive.box<Record>(name).toMap().entries.map((entry) => entry.value);
  }

  @override
  Future<Change?> save(Key key, Record record) async {
    var existing = box.get(key);
    if (existing == record) {
      return null;
    } else if (existing == null) {
      await box.put(key, record);
      return Added(key, record);
    } else {
      await box.put(key, record);
      return Updated(key, record);
    }
  }

  @override
  Future<Change?> remove(Key key) async {
    var existing = box.get(key);
    if (existing == null) {
      return null;
    } else {
      await box.delete(key);
      return Removed(key, existing);
    }
  }
}
