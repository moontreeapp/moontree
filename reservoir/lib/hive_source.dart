import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

import 'change.dart';
import 'source.dart';

class HiveSource<Record> extends Source<Record> {
  final String name;
  late final Map<String, Record>? defaults;

  Box<Record> get box => Hive.box<Record>(name);

  HiveSource(this.name, {this.defaults});

  // Return initial Hive box records to be used to populate Reservoir
  @override
  Map<String, Record> initialLoad() {
    var items =
        box.toMap().map((key, value) => MapEntry(key.toString(), value));
    return mergeMaps<String, Record>(defaults ?? {}, items);
  }

  @override
  Future<Change<Record>?> save(String key, Record record) async {
    var existing = box.get(key);
    if (existing == record) {
      return null;
    }
    await box.put(key, record);
    if (existing == null) {
      return Added(key, record,
          didOverrideDefault: defaults?.keys.contains(key) ?? false);
    }
    return Updated(key, record);
  }

  @override
  Future<Change<Record>?> remove(String key) async {
    var existing = box.get(key);
    if (existing == null) {
      return null;
    }
    await box.delete(key);
    return Removed(key, existing);
  }
}
