import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'change.dart';
import 'source.dart';

class HiveSource<Key, Record extends Equatable> extends Source<Key, Record> {
  final String name;
  late final Box<Record> box;

  HiveSource(this.name);

  @override
  void initialLoad(AddRecord<Record> addRecord) {
    box = Hive.box<Record>(name);

    // Populate initial data from Hive box
    for (var entry in box.toMap().entries) {
      addRecord(entry.value);
    }
  }

  @override
  Future<Change?> save(key, Record record) async {
    var existing = box.get(key);
    if (existing == null) {
      await box.put(key, record);
      return Added(key, record);
    } else if (existing == record) {
      return null;
    } else {
      await box.put(key, record);
      return Updated(key, record);
    }
  }

  @override
  Future<Change?> remove(key) async {
    if (box.containsKey(key)) {
      await box.delete(key);
      return Removed(key);
    }
  }
}
