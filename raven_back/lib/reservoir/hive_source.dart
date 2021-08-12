import 'package:hive/hive.dart';

import 'change.dart';
import 'reservoir.dart';
import 'source.dart';

class HiveSource<Key, Record> extends Source<Key, Record> {
  final String name;
  late final Box<Record> box;

  HiveSource(this.name);

  @override
  Stream<Change> watch(Reservoir<Key, Record> reservoir) {
    box = Hive.box<Record>(name);

    // Populate initial data from Hive box
    for (var entry in box.toMap().entries) {
      reservoir.addRecord(entry.key, entry.value);
    }

    // Subscribe to future updates to data
    return box.watch().map((BoxEvent e) {
      var key = e.key;
      Record value = e.value;
      var exists = reservoir.primaryIndex.has(key);
      if (e.deleted) return reservoir.removeRecord(key);
      if (!exists) return reservoir.addRecord(key, value);
      return reservoir.updateRecord(key, value);
    });
  }

  @override
  void save(key, Record record) {
    box.put(key, record);
  }

  @override
  void remove(key) {
    box.delete(key);
  }
}
